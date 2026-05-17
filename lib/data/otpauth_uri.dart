import '../core/totp/totp_generator.dart';
import 'account.dart';

/// Parses and builds `otpauth://totp/...` URIs (the Google Authenticator
/// Key Uri Format) — this is what TOTP QR codes encode.
class OtpAuthUri {
  /// Throws [FormatException] if [uri] is not a valid TOTP otpauth URI.
  static Account parse(String uri, {required String id}) {
    final parsed = Uri.parse(uri.trim());

    if (parsed.scheme != 'otpauth') {
      throw const FormatException('Not an otpauth URI.');
    }
    if (parsed.host != 'totp') {
      throw FormatException('Unsupported type: ${parsed.host} (totp only).');
    }

    final secret = parsed.queryParameters['secret'];
    if (secret == null || secret.isEmpty) {
      throw const FormatException('Missing "secret" parameter.');
    }

    // The label path is "Issuer:account" or just "account"; the explicit
    // issuer query parameter wins when both are present.
    final rawLabel = Uri.decodeComponent(
      parsed.path.startsWith('/') ? parsed.path.substring(1) : parsed.path,
    );
    var issuer = parsed.queryParameters['issuer'] ?? '';
    var label = rawLabel;
    if (rawLabel.contains(':')) {
      final parts = rawLabel.split(':');
      if (issuer.isEmpty) issuer = parts.first.trim();
      label = parts.sublist(1).join(':').trim();
    }

    return Account(
      id: id,
      issuer: issuer,
      label: label,
      secret: secret,
      digits: int.tryParse(parsed.queryParameters['digits'] ?? '') ?? 6,
      period: int.tryParse(parsed.queryParameters['period'] ?? '') ?? 30,
      algorithm: totpAlgorithmFromName(
        parsed.queryParameters['algorithm'] ?? 'SHA1',
      ),
    );
  }

  static String build(Account account) {
    final label = account.issuer.isEmpty
        ? account.label
        : '${account.issuer}:${account.label}';
    return Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: '/$label',
      queryParameters: {
        'secret': account.secret,
        if (account.issuer.isNotEmpty) 'issuer': account.issuer,
        'algorithm': totpAlgorithmName(account.algorithm),
        'digits': '${account.digits}',
        'period': '${account.period}',
      },
    ).toString();
  }
}
