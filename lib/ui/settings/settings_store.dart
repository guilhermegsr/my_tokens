import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// How long the app may stay unlocked in the background before it demands
/// authentication again. [immediately] preserves the original behaviour of
/// re-locking the moment the app is backgrounded.
enum LockTimeout {
  immediately(Duration.zero),
  after30s(Duration(seconds: 30)),
  after1m(Duration(minutes: 1)),
  after5m(Duration(minutes: 5));

  const LockTimeout(this.duration);

  final Duration duration;
}

/// User preferences: app-lock on/off, lock grace period, theme, etc.
///
/// The lock state is a security control, so this lives in the OS-backed
/// secure store (Android `EncryptedSharedPreferences`, key in the Keystore),
/// not a plaintext file an attacker could edit to `lockEnabled:false`.
/// Tampering fails decryption and we fall back to the safe defaults
/// (lock enabled) — fail-secure.
class SettingsStore extends ChangeNotifier {
  SettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Single JSON blob; one key keeps reads/writes atomic.
  static const _storageKey = 'mytokens_settings_v1';

  /// Legacy plaintext file, migrated then deleted on first run.
  static const _legacyFileName = 'settings.json';

  final FlutterSecureStorage _storage;

  bool _lockEnabled = true;
  LockTimeout _lockTimeout = LockTimeout.immediately;
  ThemeMode _themeMode = ThemeMode.system;
  bool _tokensHidden = false;
  DateTime? _lastBackgroundedAt;

  bool get lockEnabled => _lockEnabled;
  LockTimeout get lockTimeout => _lockTimeout;
  ThemeMode get themeMode => _themeMode;

  /// Whether the codes are masked on the home list. Remembered across
  /// restarts so a user who hides their codes does not see them re-exposed
  /// the next time the app opens.
  bool get tokensHidden => _tokensHidden;

  /// When the app was last sent to the background. Persisted so the lock
  /// grace period survives a full app kill, not just a minimise — without
  /// this, choosing any timeout still re-locks on every cold start.
  DateTime? get lastBackgroundedAt => _lastBackgroundedAt;

  Future<void>? _loading;

  /// Loads settings once; subsequent calls await the same future so callers
  /// that need a settled value (e.g. the lock gate) can rely on it.
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      var raw = await _storage.read(key: _storageKey);
      raw ??= await _migrateLegacyFile();
      if (raw == null) return;
      _applyJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt, unreadable, or tampered settings fall back to the safe
      // defaults above — crucially, lockEnabled stays true (fail-secure).
    } finally {
      notifyListeners();
    }
  }

  void _applyJson(Map<String, dynamic> json) {
    _lockEnabled = json['lockEnabled'] as bool? ?? _lockEnabled;
    _lockTimeout = LockTimeout.values.firstWhere(
      (t) => t.name == json['lockTimeout'],
      orElse: () => _lockTimeout,
    );
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == json['themeMode'],
      orElse: () => _themeMode,
    );
    _tokensHidden = json['tokensHidden'] as bool? ?? _tokensHidden;
    final lastBg = json['lastBackgroundedAt'] as int?;
    if (lastBg != null) {
      _lastBackgroundedAt = DateTime.fromMillisecondsSinceEpoch(lastBg);
    }
  }

  /// One-time import of the old plaintext settings so upgrading users keep
  /// their theme/timeout. The file is deleted afterwards: leaving it would
  /// re-expose the tamperable lock state we are moving away from.
  Future<String?> _migrateLegacyFile() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$_legacyFileName');
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      await _storage.write(key: _storageKey, value: raw);
      await file.delete();
      return raw;
    } catch (_) {
      return null;
    }
  }

  Future<void> setLockEnabled(bool value) async {
    if (_lockEnabled == value) return;
    _lockEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLockTimeout(LockTimeout value) async {
    if (_lockTimeout == value) return;
    _lockTimeout = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setTokensHidden(bool value) async {
    if (_tokensHidden == value) return;
    _tokensHidden = value;
    notifyListeners();
    await _persist();
  }

  /// Records "the app just went to the background" so a later cold start can
  /// tell whether we are still inside the grace period. Deliberately does
  /// not notify listeners — this is bookkeeping, not a visible setting.
  Future<void> recordBackgrounded() async {
    _lastBackgroundedAt = DateTime.now();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode({
          'lockEnabled': _lockEnabled,
          'lockTimeout': _lockTimeout.name,
          'themeMode': _themeMode.name,
          'tokensHidden': _tokensHidden,
          'lastBackgroundedAt': _lastBackgroundedAt?.millisecondsSinceEpoch,
        }),
      );
    } catch (_) {
      // A failed write only loses the preference; never crash the UI.
    }
  }
}
