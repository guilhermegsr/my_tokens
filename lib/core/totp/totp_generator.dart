import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Hash algorithms allowed by the otpauth Key Uri Format.
enum TotpAlgorithm { sha1, sha256, sha512 }

TotpAlgorithm totpAlgorithmFromName(String name) {
  switch (name.toUpperCase()) {
    case 'SHA256':
      return TotpAlgorithm.sha256;
    case 'SHA512':
      return TotpAlgorithm.sha512;
    case 'SHA1':
    default:
      return TotpAlgorithm.sha1;
  }
}

String totpAlgorithmName(TotpAlgorithm algorithm) {
  switch (algorithm) {
    case TotpAlgorithm.sha256:
      return 'SHA256';
    case TotpAlgorithm.sha512:
      return 'SHA512';
    case TotpAlgorithm.sha1:
      return 'SHA1';
  }
}

/// A computed one-time password together with the number of seconds it
/// stays valid, so callers can drive a countdown without re-deriving it.
class TotpCode {
  const TotpCode({required this.code, required this.secondsRemaining});

  final String code;
  final int secondsRemaining;
}

/// Stateless TOTP/HOTP implementation (RFC 6238 / RFC 4226).
///
/// Kept free of any Flutter or storage dependency so it can be unit tested
/// in isolation against the RFC test vectors.
class TotpGenerator {
  const TotpGenerator();

  /// [at] is injectable to make the time-dependent output testable; it
  /// defaults to the current wall clock.
  TotpCode generate(
    String secretBase32, {
    int digits = 6,
    int period = 30,
    TotpAlgorithm algorithm = TotpAlgorithm.sha1,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final unixSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final counter = unixSeconds ~/ period;
    final code = _hotp(
      _decodeBase32(secretBase32),
      counter,
      digits: digits,
      algorithm: algorithm,
    );
    return TotpCode(
      code: code,
      secondsRemaining: period - (unixSeconds % period),
    );
  }

  String _hotp(
    Uint8List key,
    int counter, {
    required int digits,
    required TotpAlgorithm algorithm,
  }) {
    final message = Uint8List(8);
    var remaining = counter;
    for (var i = 7; i >= 0; i--) {
      message[i] = remaining & 0xff;
      remaining >>= 8;
    }

    final Hash hash;
    switch (algorithm) {
      case TotpAlgorithm.sha256:
        hash = sha256;
      case TotpAlgorithm.sha512:
        hash = sha512;
      case TotpAlgorithm.sha1:
        hash = sha1;
    }

    final digest = Hmac(hash, key).convert(message).bytes;
    // RFC 4226 dynamic truncation.
    final offset = digest[digest.length - 1] & 0x0f;
    final binary = ((digest[offset] & 0x7f) << 24) |
        ((digest[offset + 1] & 0xff) << 16) |
        ((digest[offset + 2] & 0xff) << 8) |
        (digest[offset + 3] & 0xff);

    return (binary % _pow10(digits)).toString().padLeft(digits, '0');
  }

  int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  /// Decodes RFC 4648 base32. Whitespace, padding and case are tolerated
  /// because secrets pasted by users and embedded in QR codes vary wildly.
  Uint8List _decodeBase32(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final normalized = input.replaceAll(RegExp(r'[\s=]'), '').toUpperCase();
    if (normalized.isEmpty) {
      throw const FormatException('Empty secret.');
    }

    var buffer = 0;
    var bits = 0;
    final output = <int>[];
    for (final char in normalized.split('')) {
      final value = alphabet.indexOf(char);
      if (value < 0) {
        throw FormatException('Invalid base32 character: "$char".');
      }
      buffer = (buffer << 5) | value;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        output.add((buffer >> bits) & 0xff);
      }
    }
    return Uint8List.fromList(output);
  }
}
