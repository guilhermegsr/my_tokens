import '../core/totp/totp_generator.dart';

const int kMaxAccountIdLength = 128;
const int kMaxAccountTextLength = 256;

class Account {
  Account({
    required this.id,
    required this.issuer,
    required this.label,
    required this.secret,
    this.digits = 6,
    this.period = 30,
    this.algorithm = TotpAlgorithm.sha1,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final digits = _optionalInt(json, 'digits') ?? 6;
    final period = _optionalInt(json, 'period') ?? 30;
    final algorithm = _optionalString(json, 'algorithm');
    return Account(
      id: _requiredString(json, 'id', kMaxAccountIdLength),
      issuer: _optionalString(json, 'issuer'),
      label: _optionalString(json, 'label'),
      secret: validateTotpSecret(
        _requiredString(json, 'secret', kMaxSecretLength * 2),
      ),
      // Clamp rather than throw: one tampered/legacy record must not make
      // the whole vault fail to load.
      digits: isValidTotpDigits(digits) ? digits : 6,
      period: isValidTotpPeriod(period) ? period : 30,
      algorithm: totpAlgorithmFromName(algorithm.isEmpty ? 'SHA1' : algorithm),
    );
  }

  final String id;
  final String issuer;
  final String label;
  final String secret;
  final int digits;
  final int period;
  final TotpAlgorithm algorithm;

  String get displayName => issuer.isEmpty ? label : '$issuer : $label';

  /// Stable cryptographic identity: two accounts with the same shared
  /// secret are the same account, regardless of id or label. Used to keep
  /// the same account from being added twice.
  String get identity => normalizeTotpSecret(secret);

  Map<String, dynamic> toJson() => {
    'id': id,
    'issuer': issuer,
    'label': label,
    'secret': secret,
    'digits': digits,
    'period': period,
    'algorithm': totpAlgorithmName(algorithm),
  };

  Account copyWith({String? issuer, String? label, String? secret}) => Account(
    id: id,
    issuer: issuer ?? this.issuer,
    label: label ?? this.label,
    secret: secret == null ? this.secret : validateTotpSecret(secret),
    digits: digits,
    period: period,
    algorithm: algorithm,
  );

  static String _requiredString(
    Map<String, dynamic> json,
    String key,
    int maxLength,
  ) {
    final value = json[key];
    if (value is! String || value.isEmpty || value.length > maxLength) {
      throw FormatException('Invalid "$key".');
    }
    return value;
  }

  static String _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    if (value is! String || value.length > kMaxAccountTextLength) {
      throw FormatException('Invalid "$key".');
    }
    return value;
  }

  static int? _optionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! int) throw FormatException('Invalid "$key".');
    return value;
  }
}
