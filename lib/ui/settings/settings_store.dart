import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

/// User preferences: app-lock on/off, lock grace period, and theme.
///
/// Persisted as a small plaintext JSON file (no secrets here) using the
/// same offline, dependency-free approach as the rest of the app.
class SettingsStore extends ChangeNotifier {
  SettingsStore();

  static const _fileName = 'settings.json';

  bool _lockEnabled = true;
  LockTimeout _lockTimeout = LockTimeout.immediately;
  ThemeMode _themeMode = ThemeMode.system;

  bool get lockEnabled => _lockEnabled;
  LockTimeout get lockTimeout => _lockTimeout;
  ThemeMode get themeMode => _themeMode;

  Future<void>? _loading;
  File? _cachedFile;

  /// Loads settings once; subsequent calls await the same future so callers
  /// that need a settled value (e.g. the lock gate) can rely on it.
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _lockEnabled = json['lockEnabled'] as bool? ?? _lockEnabled;
      _lockTimeout = LockTimeout.values.firstWhere(
        (t) => t.name == json['lockTimeout'],
        orElse: () => _lockTimeout,
      );
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => _themeMode,
      );
    } catch (_) {
      // Corrupt or unreadable settings simply fall back to safe defaults.
    } finally {
      notifyListeners();
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

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return _cachedFile ??= File('${dir.path}/$_fileName');
  }

  Future<void> _persist() async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode({
        'lockEnabled': _lockEnabled,
        'lockTimeout': _lockTimeout.name,
        'themeMode': _themeMode.name,
      }));
    } catch (_) {
      // A failed write only loses the preference; never crash the UI.
    }
  }
}
