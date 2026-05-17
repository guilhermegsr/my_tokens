import 'package:flutter_test/flutter_test.dart';
import 'package:my_tokens/core/totp/totp_generator.dart';

void main() {
  const totp = TotpGenerator();

  // RFC 6238 Appendix B seeds are ASCII strings. We base32-encode them
  // here so a hand-typed encoding mistake can't mask a real bug.
  String base32Encode(List<int> bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    var buffer = 0;
    var bits = 0;
    final out = StringBuffer();
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        out.write(alphabet[(buffer >> bits) & 0x1f]);
      }
    }
    if (bits > 0) {
      out.write(alphabet[(buffer << (5 - bits)) & 0x1f]);
    }
    return out.toString();
  }

  final seedSha1 = base32Encode('12345678901234567890'.codeUnits);
  final seedSha256 =
      base32Encode('12345678901234567890123456789012'.codeUnits);
  final seedSha512 = base32Encode(
    '1234567890123456789012345678901234567890123456789012345678901234'
        .codeUnits,
  );

  String codeAt(String seed, int unixSeconds, TotpAlgorithm algorithm) {
    return totp
        .generate(
          seed,
          digits: 8,
          period: 30,
          algorithm: algorithm,
          at: DateTime.fromMillisecondsSinceEpoch(
            unixSeconds * 1000,
            isUtc: true,
          ),
        )
        .code;
  }

  group('RFC 6238 test vectors (SHA1)', () {
    final vectors = {
      59: '94287082',
      1111111109: '07081804',
      1111111111: '14050471',
      1234567890: '89005924',
      2000000000: '69279037',
      20000000000: '65353130',
    };
    vectors.forEach((time, expected) {
      test('T=$time', () {
        expect(codeAt(seedSha1, time, TotpAlgorithm.sha1), expected);
      });
    });
  });

  group('RFC 6238 test vectors (SHA256)', () {
    final vectors = {
      59: '46119246',
      1111111109: '68084774',
      2000000000: '90698825',
    };
    vectors.forEach((time, expected) {
      test('T=$time', () {
        expect(codeAt(seedSha256, time, TotpAlgorithm.sha256), expected);
      });
    });
  });

  group('RFC 6238 test vectors (SHA512)', () {
    final vectors = {
      59: '90693936',
      1111111109: '25091201',
      2000000000: '38618901',
    };
    vectors.forEach((time, expected) {
      test('T=$time', () {
        expect(codeAt(seedSha512, time, TotpAlgorithm.sha512), expected);
      });
    });
  });

  test('default code has six digits', () {
    expect(totp.generate(seedSha1).code.length, 6);
  });

  test('secondsRemaining stays within (0, period]', () {
    final result = totp.generate(
      seedSha1,
      period: 30,
      at: DateTime.fromMillisecondsSinceEpoch(1000500, isUtc: true),
    );
    expect(result.secondsRemaining, inInclusiveRange(1, 30));
  });

  test('tolerates spaced and lowercase secrets', () {
    final spaced =
        totp.generate('gezd gnbv gy3t qojq gezd gnbv gy3t qojq');
    expect(spaced.code, totp.generate(seedSha1).code);
  });

  test('rejects invalid base32', () {
    expect(() => totp.generate('0189!'), throwsFormatException);
  });
}
