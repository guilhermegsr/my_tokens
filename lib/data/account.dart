import '../core/totp/totp_generator.dart';

/// A TOTP account. [secret] is the base32 shared secret; it only ever
/// exists in memory and inside the encrypted vault, never as plaintext.
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

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        issuer: (json['issuer'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        secret: json['secret'] as String,
        digits: (json['digits'] as int?) ?? 6,
        period: (json['period'] as int?) ?? 30,
        algorithm:
            totpAlgorithmFromName((json['algorithm'] as String?) ?? 'SHA1'),
      );

  final String id;
  final String issuer;
  final String label;
  final String secret;
  final int digits;
  final int period;
  final TotpAlgorithm algorithm;

  /// List header text, e.g. "Google : jane.doe@gmail.com".
  String get displayName => issuer.isEmpty ? label : '$issuer : $label';

  /// Stable cryptographic identity: two accounts with the same shared
  /// secret are the same account, regardless of id or label. Used to keep
  /// the same account from being added twice.
  String get identity => secret.replaceAll(' ', '').toUpperCase();

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
        secret: secret ?? this.secret,
        digits: digits,
        period: period,
        algorithm: algorithm,
      );
}
