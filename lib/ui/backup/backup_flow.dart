import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/crypto/cipher.dart';
import '../../data/account.dart';
import '../../l10n/app_localizations.dart';
import '../account_store.dart';
import '../app_theme.dart';
import '../security/biometric_gate.dart';
import '../widgets/app_notification.dart';

enum _ImportConflictChoice { replaceWithBackup, keepExisting }

/// Password-protected backup export/import.
///
/// File format (`.mytokens`, JSON): `{app, version, kdf, salt, payload}`,
/// where `payload` is the AES-GCM [Cipher] envelope of the accounts and
/// the key is Argon2id(password, salt).
class BackupFlow {
  const BackupFlow._();

  static const _magic = 'MyTokens';
  static const _version = 1;
  static const _saltLength = 16;
  static const _maxBackupBytes = 1024 * 1024;
  static const _maxBackupAccounts = 500;

  static Future<void> export(BuildContext context) async {
    final store = context.read<AccountStore>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (store.accounts.isEmpty) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupNoAccounts,
        kind: NotificationKind.info,
      );
      return;
    }

    final password = await _promptPassword(context, isNewPassword: true);
    if (password == null || !context.mounted) return;
    if (!await BiometricGate.requireDeviceAuth(context) || !context.mounted) {
      return;
    }

    final accountsJson = jsonEncode(
      store.accounts.map((a) => a.toJson()).toList(),
    );

    String? filePath;
    try {
      filePath = await _withProgress(context, l10n.backupWorking, () async {
        final salt = _secureRandomBytes(_saltLength);
        final key = await PasswordKeyDeriver.derive(
          password: password,
          salt: salt,
        );
        final envelope = await Cipher(key).encrypt(accountsJson);
        final suffix = DateTime.now().microsecondsSinceEpoch;
        final file = File(
          '${(await getTemporaryDirectory()).path}/mytokens-backup-$suffix.mytokens',
        );
        await file.writeAsString(
          jsonEncode({
            'app': _magic,
            'version': _version,
            'kdf': 'argon2id',
            'salt': base64Encode(salt),
            'payload': envelope,
          }),
        );
        return file.path;
      });

      if (!context.mounted) return;
      await BiometricGate.withoutAutoLock(
        () => Share.shareXFiles([
          XFile(filePath!),
        ], subject: l10n.backupShareSubject),
      );
    } catch (_) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupFailed,
        kind: NotificationKind.error,
      );
      return;
    } finally {
      if (filePath != null) {
        try {
          await File(filePath).delete();
        } catch (_) {}
      }
    }
  }

  static Future<void> import(BuildContext context) async {
    final store = context.read<AccountStore>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final FilePickerResult? picked;
    try {
      picked = await BiometricGate.withoutAutoLock(
        () => FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
        ),
      );
    } catch (_) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupFailed,
        kind: NotificationKind.error,
      );
      return;
    }
    if (picked == null || picked.files.isEmpty || !context.mounted) return;

    final Map<String, dynamic> header;
    try {
      final platformFile = picked.files.single;
      final bytes = platformFile.bytes ??
          (platformFile.path != null
              ? await File(platformFile.path!).readAsBytes()
              : null);
      if (bytes == null) throw const FormatException('Missing file data.');
      if (bytes.length > _maxBackupBytes) {
        throw const FormatException('Backup too large.');
      }
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid backup header.');
      }
      header = decoded;
    } catch (_) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupCorrupted,
        kind: NotificationKind.error,
      );
      return;
    }
    if (header['app'] != _magic) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupNotMyTokens,
        kind: NotificationKind.error,
      );
      return;
    }

    final List<int> salt;
    final String payload;
    try {
      salt = _readSalt(header);
      payload = _readPayload(header);
    } catch (_) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupCorrupted,
        kind: NotificationKind.error,
      );
      return;
    }

    if (!context.mounted) return;
    final password = await _promptPassword(context, isNewPassword: false);
    if (password == null || !context.mounted) return;

    List<Account> imported;
    try {
      imported = await _withProgress(context, l10n.backupWorking, () async {
        final key = await PasswordKeyDeriver.derive(
          password: password,
          salt: salt,
        );
        final clear = await Cipher(key).decrypt(payload);
        if (clear.length > _maxBackupBytes) {
          throw const FormatException('Backup payload too large.');
        }
        return _readAccounts(clear);
      });
    } on SecretBoxAuthenticationError {
      // The MAC didn't verify: the derived key is wrong, i.e. the wrong
      // password (or a tampered file).
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupWrongPassword,
        kind: NotificationKind.error,
      );
      return;
    } on FormatException {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupCorrupted,
        kind: NotificationKind.error,
      );
      return;
    } catch (_) {
      AppNotification.showWith(
        messenger,
        theme,
        l10n.backupFailed,
        kind: NotificationKind.error,
      );
      return;
    }

    // Smart merge: an account is identified by its secret (the actual
    // credential), not by its locally-generated id, so a backup taken on
    // another device still reconciles correctly. We only interrupt the
    // user with a question when there is a genuine conflict to resolve.
    final currentBySecret = {for (final a in store.accounts) a.identity: a};
    final fresh = <Account>[];
    final conflicts = <Account>[];
    for (final incoming in imported) {
      if (currentBySecret.containsKey(incoming.identity)) {
        conflicts.add(incoming);
      } else {
        fresh.add(incoming);
      }
    }

    var importedCount = fresh.length;
    final List<Account> result;
    if (conflicts.isEmpty) {
      result = [...store.accounts, ...fresh];
    } else {
      if (!context.mounted) return;
      final choice = await _promptConflict(context, conflicts.length);
      if (choice == null) return;

      final incomingBySecret = {for (final a in imported) a.identity: a};
      final replace = choice == _ImportConflictChoice.replaceWithBackup;
      result = [
        for (final a in store.accounts)
          replace ? (incomingBySecret[a.identity] ?? a) : a,
        ...fresh,
      ];
      if (replace) importedCount += conflicts.length;
    }

    await store.replaceAll(result);
    AppNotification.showWith(
      messenger,
      theme,
      l10n.backupImported(importedCount),
      kind: NotificationKind.success,
    );
  }

  /// Runs [task] behind a non-dismissible progress dialog so slow key
  /// derivation never looks like a frozen or broken screen.
  static Future<T> _withProgress<T>(
    BuildContext context,
    String message,
    Future<T> Function() task,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(message: message),
    );
    try {
      return await task();
    } finally {
      navigator.pop();
    }
  }

  static List<int> _secureRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static List<int> _readSalt(Map<String, dynamic> header) {
    _validateHeaderFormat(header);
    final rawSalt = header['salt'];
    if (rawSalt is! String || rawSalt.length > 128) {
      throw const FormatException('Invalid salt.');
    }
    final salt = base64Decode(rawSalt);
    if (salt.length != _saltLength) {
      throw const FormatException('Invalid salt.');
    }
    return salt;
  }

  static String _readPayload(Map<String, dynamic> header) {
    final payload = header['payload'];
    if (payload is! String ||
        payload.isEmpty ||
        payload.length > _maxBackupBytes) {
      throw const FormatException('Invalid payload.');
    }
    return payload;
  }

  static void _validateHeaderFormat(Map<String, dynamic> header) {
    if (header['version'] != _version || header['kdf'] != 'argon2id') {
      throw const FormatException('Unsupported backup format.');
    }
  }

  static List<Account> _readAccounts(String clear) {
    final decoded = jsonDecode(clear);
    if (decoded is! List || decoded.length > _maxBackupAccounts) {
      throw const FormatException('Invalid account list.');
    }
    return [for (final entry in decoded) Account.fromJson(_jsonMap(entry))];
  }

  static Map<String, dynamic> _jsonMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid account.');
  }

  static bool _isWeakBackupPassword(String value) {
    final compact = value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (value.length < 16) return true;
    if (value.runes.toSet().length < 4) return true;
    if (RegExp(r'^(.)\1+$').hasMatch(value)) return true;
    const common = [
      'password',
      'passw0rd',
      'qwerty',
      'letmein',
      'admin',
      'senha',
    ];
    if (common.any(compact.contains)) return true;
    if ('abcdefghijklmnopqrstuvwxyz'.contains(compact) ||
        'zyxwvutsrqponmlkjihgfedcba'.contains(compact) ||
        '01234567890123456789'.contains(compact) ||
        '98765432109876543210'.contains(compact)) {
      return true;
    }
    return false;
  }

  static Future<String?> _promptPassword(
    BuildContext context, {
    required bool isNewPassword,
  }) {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupPasswordTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNewPassword
                    ? l10n.backupPasswordSetHint
                    : l10n.backupPasswordEnterHint,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.fieldPassword),
                // The export file leaves the device, so its password is the
                // only thing standing between it and offline brute force.
                // Import only checks non-empty: rejecting a legacy short
                // password would lock the user out of their own data.
                validator: (v) {
                  final value = v ?? '';
                  if (isNewPassword) {
                    return _isWeakBackupPassword(value)
                        ? l10n.fieldPasswordTooShort
                        : null;
                  }
                  return value.isEmpty ? l10n.fieldPasswordRequired : null;
                },
              ),
              if (isNewPassword) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.fieldPasswordConfirm,
                  ),
                  validator: (v) => v != passwordController.text
                      ? l10n.fieldPasswordMismatch
                      : null,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, passwordController.text);
              }
            },
            child: Text(l10n.actionContinue),
          ),
        ],
      ),
    );
  }

  /// Asked only when the backup contains accounts that already exist, to
  /// decide whether those should be overwritten with the backup's version.
  static Future<_ImportConflictChoice?> _promptConflict(
    BuildContext context,
    int conflictCount,
  ) {
    final l10n = AppLocalizations.of(context);
    return showDialog<_ImportConflictChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importConflictTitle),
        content: Text(l10n.importConflictQuestion(conflictCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _ImportConflictChoice.keepExisting),
            child: Text(l10n.importKeepExisting),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, _ImportConflictChoice.replaceWithBackup),
            child: Text(l10n.importReplaceWithBackup),
          ),
        ],
      ),
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: palette.title, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
