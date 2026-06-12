import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Bounds enforced on untrusted otpauth params (scanned QR, imported
/// backup): `period <= 0` divides by zero and a huge `digits` exhausts
/// CPU/memory in `_pow10`/`padLeft`.
const int kMinDigits = 6;
const int kMaxDigits = 10;
const int kMinPeriod = 1;
const int kMaxPeriod = 600;
const int kMaxSecretLength = 256;

final RegExp _base32SecretPattern = RegExp(r'^[A-Z2-7]+$');

bool isValidTotpDigits(int digits) =>
    digits >= kMinDigits && digits <= kMaxDigits;
bool isValidTotpPeriod(int period) =>
    period >= kMinPeriod && period <= kMaxPeriod;

String normalizeTotpSecret(String secret) =>
    secret.replaceAll(RegExp(r'[\s=]'), '').toUpperCase();

String validateTotpSecret(String secret) {
  final normalized = normalizeTotpSecret(secret);
  if (normalized.isEmpty || normalized.length > kMaxSecretLength) {
    throw const FormatException('Invalid secret length.');
  }
  if (!_base32SecretPattern.hasMatch(normalized)) {
    throw const FormatException('Invalid base32 secret.');
  }
  _decodeBase32(normalized);
  return normalized;
}

/// Decodes RFC 4648 base32. Whitespace, padding and case are tolerated
/// because secrets pasted by users and embedded in QR codes vary wildly.
Uint8List _decodeBase32(String input) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  final normalized = normalizeTotpSecret(input);
  if (normalized.isEmpty || normalized.length > kMaxSecretLength) {
    throw const FormatException('Invalid secret length.');
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
  if (output.isEmpty) {
    throw const FormatException('Invalid base32 secret.');
  }
  return Uint8List.fromList(output);
}

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

  TotpCode generate(
    String secretBase32, {
    int digits = 6,
    int period = 30,
    TotpAlgorithm algorithm = TotpAlgorithm.sha1,
    DateTime? at,
  }) {
    // Last line of defence: a bad value slipping past parsing/storage must
    // still never divide by zero or hang the UI here.
    final safeDigits = isValidTotpDigits(digits) ? digits : 6;
    final safePeriod = isValidTotpPeriod(period) ? period : 30;
    final now = at ?? DateTime.now();
    final unixSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final counter = unixSeconds ~/ safePeriod;
    final code = _hotp(
      _decodeBase32(secretBase32),
      counter,
      digits: safeDigits,
      algorithm: algorithm,
    );
    return TotpCode(
      code: code,
      secondsRemaining: safePeriod - (unixSeconds % safePeriod),
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
    final binary =
        ((digest[offset] & 0x7f) << 24) |
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
}
