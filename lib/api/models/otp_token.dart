import 'package:dartx/dartx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_token.g.dart';

@JsonSerializable()
class OTPToken {
  @JsonKey(name: 'id', defaultValue: "")
  String id;
  final String name;
  final String secret;
  @JsonKey(name: 'issuer', defaultValue: "")
  final String? issuer;
  @JsonKey(name: 'pinned_time', defaultValue: null)
  DateTime? pinnedTime;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  OTPToken({
    this.id = "",
    required this.name,
    required this.secret,
    this.issuer,
    this.pinnedTime,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) {
    if (id.isEmpty) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  factory OTPToken.fromJson(Map<String, dynamic> json) =>
      _$OTPTokenFromJson(json);

  Map<String, dynamic> toJson() => _$OTPTokenToJson(this);

  factory OTPToken.fromUri(Uri uri) {
    if (uri.scheme != 'otpauth' || uri.host != 'totp') {
      throw const FormatException('Invalid OTP URI format');
    }

    final secret = uri.queryParameters['secret'];
    if (secret == null || secret.isEmpty) {
      throw const FormatException('Secret is required');
    }

    String name;
    String? issuer;

    final path =
        Uri.decodeComponent(uri.path.substring(1)); // Remove leading '/'

    if (path.contains(':')) {
      final parts = path.split(':');
      issuer = parts[0];
      name = parts[1];
    } else {
      name = path;
      issuer = uri.queryParameters['issuer'] ?? '';
    }

    // If issuer is provided in query parameters, it takes precedence
    if (uri.queryParameters['issuer'] != null) {
      issuer = uri.queryParameters['issuer']!;
    }

    return OTPToken(
      id: '',
      name: name,
      secret: secret,
      issuer: issuer,
    );
  }

  @override
  String toString() => issuer.isNotNullOrEmpty ? '$issuer: $name' : name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OTPToken &&
        other.name == name &&
        other.secret == secret &&
        other.issuer == issuer;
  }

  @override
  int get hashCode => Object.hash(name, secret, issuer);

  bool get isPinned => pinnedTime != null;
}
