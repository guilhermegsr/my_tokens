import 'package:flutter_test/flutter_test.dart';
import 'package:my_tokens/core/totp/totp_generator.dart';
import 'package:my_tokens/data/otpauth_uri.dart';

void main() {
  test('parses issuer embedded in the path', () {
    final account = OtpAuthUri.parse(
      'otpauth://totp/Google:jane.doe@gmail.com?secret=JBSWY3DPEHPK3PXP&issuer=Google',
      id: '1',
    );
    expect(account.issuer, 'Google');
    expect(account.label, 'jane.doe@gmail.com');
    expect(account.secret, 'JBSWY3DPEHPK3PXP');
    expect(account.digits, 6);
    expect(account.algorithm, TotpAlgorithm.sha1);
  });

  test('parses custom parameters', () {
    final account = OtpAuthUri.parse(
      'otpauth://totp/ACME?secret=AAAA&digits=8&period=60&algorithm=SHA256',
      id: '2',
    );
    expect(account.digits, 8);
    expect(account.period, 60);
    expect(account.algorithm, TotpAlgorithm.sha256);
  });

  test('rejects a non-otpauth scheme', () {
    expect(
      () => OtpAuthUri.parse('https://example.com', id: '3'),
      throwsFormatException,
    );
  });

  test('rejects a URI without a secret', () {
    expect(
      () => OtpAuthUri.parse('otpauth://totp/Account', id: '4'),
      throwsFormatException,
    );
  });

  test('build and parse round-trip', () {
    final original = OtpAuthUri.parse(
      'otpauth://totp/GitHub:janedoe?secret=JBSWY3DPEHPK3PXP&issuer=GitHub',
      id: '5',
    );
    final rebuilt = OtpAuthUri.parse(OtpAuthUri.build(original), id: '5');
    expect(rebuilt.issuer, original.issuer);
    expect(rebuilt.label, original.label);
    expect(rebuilt.secret, original.secret);
  });
}
