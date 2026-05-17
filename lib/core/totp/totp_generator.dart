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
  ///
  /// [steam] switches to the Steam Guard variant: the same HMAC-SHA1
  /// truncation, but rendered as 5 characters from Steam's custom
  /// alphabet instead of decimal digits. The secret is still base32 — a
  /// Steam `shared_secret` (base64) is normalized to base32 on
  /// enrollment, so this path stays uniform.
  TotpCode generate(
    String secretBase32, {
    int digits = 6,
    int period = 30,
    TotpAlgorithm algorithm = TotpAlgorithm.sha1,
    bool steam = false,
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
      steam: steam,
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
    bool steam = false,
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

    if (steam) return _steamFormat(binary);
    return (binary % _pow10(digits)).toString().padLeft(digits, '0');
  }

  /// Steam Guard's 5-character encoding: repeatedly take the truncated
  /// value modulo a 26-symbol alphabet that omits ambiguous characters
  /// and vowels.
  static const _steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';

  String _steamFormat(int binary) {
    var value = binary;
    final buffer = StringBuffer();
    for (var i = 0; i < 5; i++) {
      buffer.write(_steamAlphabet[value % _steamAlphabet.length]);
      value ~/= _steamAlphabet.length;
    }
    return buffer.toString();
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

/// RFC 4648 base32 (unpadded). Used to normalize a Steam `shared_secret`
/// (delivered as base64) into the base32 the rest of the app stores, so
/// generation, dedup and backup all stay on one secret encoding.
String base32Encode(List<int> bytes) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  var buffer = 0;
  var bits = 0;
  final output = StringBuffer();
  for (final byte in bytes) {
    buffer = (buffer << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      output.write(alphabet[(buffer >> bits) & 0x1f]);
    }
  }
  if (bits > 0) {
    output.write(alphabet[(buffer << (5 - bits)) & 0x1f]);
  }
  return output.toString();
}
