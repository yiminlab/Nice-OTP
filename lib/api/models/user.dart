import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  @JsonKey(name: 'email_verified', defaultValue: false)
  final bool emailVerified;

  @JsonKey(name: 'sync_enabled', defaultValue: false)
  bool syncEnabled;

  @JsonKey(name: 'last_sync_at')
  final DateTime? lastSyncAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    required this.id,
    this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.isActive,
    required this.emailVerified,
    required this.syncEnabled,
    this.lastSyncAt,
    required this.createdAt,
  });

  // 添加一个便捷的 nickname getter 用于兼容旧代码
  String get nickname => displayName ?? username ?? email ?? 'User';

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isActive,
    bool? emailVerified,
    bool? syncEnabled,
    DateTime? lastSyncAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
