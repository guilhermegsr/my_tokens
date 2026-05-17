import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Authenticated encryption envelope (AES-256-GCM), serialized as a small
/// base64 JSON object. Used by both the local vault and the
/// password-protected backup file.
class Cipher {
  Cipher(this._key) : _algorithm = AesGcm.with256bits();

  final List<int> _key;
  final AesGcm _algorithm;

  Future<String> encrypt(String plaintext) async {
    final box = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(_key),
    );
    return jsonEncode({
      'v': 1,
      'nonce': base64Encode(box.nonce),
      'data': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  /// Throws if the MAC does not verify (wrong key or tampered ciphertext) —
  /// the caller relies on this to detect an incorrect backup password.
  Future<String> decrypt(String envelope) async {
    final json = jsonDecode(envelope) as Map<String, dynamic>;
    final box = SecretBox(
      base64Decode(json['data'] as String),
      nonce: base64Decode(json['nonce'] as String),
      mac: Mac(base64Decode(json['mac'] as String)),
    );
    final clear = await _algorithm.decrypt(box, secretKey: SecretKey(_key));
    return utf8.decode(clear);
  }
}

/// Derives a 256-bit key from a user password with Argon2id. Only used for
/// backups: the password is what protects the exported file.
class PasswordKeyDeriver {
  static Future<Uint8List> derive({
    required String password,
    required List<int> salt,
  }) async {
    final argon2id = Argon2id(
      memory: 19456, // ~19 MiB, OWASP-recommended profile
      iterations: 2,
      parallelism: 1,
      hashLength: 32,
    );
    final secretKey = await argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return Uint8List.fromList(await secretKey.extractBytes());
  }
}
