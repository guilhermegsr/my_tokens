import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import '../core/crypto/cipher.dart';
import '../core/crypto/key_store.dart';
import 'account.dart';

/// Persists every account in a single AES-256-GCM encrypted file
/// (`vault.enc`). The encryption key comes from [KeyStore].
class AccountRepository {
  AccountRepository({KeyStore? keyStore}) : _keyStore = keyStore ?? KeyStore();

  final KeyStore _keyStore;
  Cipher? _cipher;
  File? _vaultFile;

  Future<Cipher> get _cipherInstance async {
    return _cipher ??= Cipher(await _keyStore.getOrCreateKey());
  }

  Future<File> get _file async {
    if (_vaultFile != null) return _vaultFile!;
    final directory = await getApplicationSupportDirectory();
    return _vaultFile = File('${directory.path}/vault.enc');
  }

  Future<List<Account>> load() async {
    final file = await _file;
    if (!await file.exists()) return [];
    final cipher = await _cipherInstance;
    final json = await cipher.decrypt(await file.readAsString());
    final decoded = jsonDecode(json);
    if (decoded is! List) throw const FormatException('Invalid vault.');
    final accounts = <Account>[];
    for (final entry in decoded) {
      try {
        if (entry is Map<String, dynamic>) {
          accounts.add(Account.fromJson(entry));
        }
      } on FormatException {
        // Invalid legacy/tampered entries are unusable and must not crash the app.
      }
    }
    return accounts;
  }

  Future<void> save(List<Account> accounts) async {
    final cipher = await _cipherInstance;
    final payload = jsonEncode(accounts.map((a) => a.toJson()).toList());
    final file = await _file;
    // Write-then-rename keeps the vault atomic: a crash mid-write can never
    // leave a half-written, undecryptable file.
    final suffix =
        '${DateTime.now().microsecondsSinceEpoch}-'
        '${Random().nextInt(1 << 32)}';
    final temp = File('${file.path}.$suffix.tmp');
    try {
      await temp.writeAsString(await cipher.encrypt(payload), flush: true);
      await temp.rename(file.path);
    } finally {
      try {
        if (await temp.exists()) await temp.delete();
      } catch (_) {}
    }
  }
}
