import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the vault's AES-256 key inside the OS-backed secure store
/// (Android Keystore / iOS Keychain). The key never hits disk in cleartext.
class KeyStore {
  KeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _keyAlias = 'mytokens_vault_key_v1';

  final FlutterSecureStorage _storage;

  Future<Uint8List> getOrCreateKey() async {
    final stored = await _storage.read(key: _keyAlias);
    if (stored != null) {
      return Uint8List.fromList(base64Decode(stored));
    }
    final key = _secureRandomBytes(32);
    await _storage.write(key: _keyAlias, value: base64Encode(key));
    return key;
  }

  Uint8List _secureRandomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }
}
