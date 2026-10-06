import 'package:flutter/foundation.dart';
import 'package:two_factor_authentication/api/models/otp_token.dart';
import 'package:two_factor_authentication/api/models/token_update_request.dart';

class OTPTokenStore {
  static const int maxAccounts = 15;
  // 单例模式
  static final OTPTokenStore _instance = OTPTokenStore._internal();
  factory OTPTokenStore() => _instance;
  OTPTokenStore._internal();

  // 使用 ValueNotifier 管理 tokens 列表
  final ValueNotifier<List<OTPToken>> tokens =
      ValueNotifier<List<OTPToken>>([]);

  // 获取所有 tokens
  List<OTPToken> get allTokens => tokens.value;

  // 获取排序后的 tokens
  // 先排pinned 时间，再按创建时间排序
  List<OTPToken> get sortedTokens {
    final pinnedTokens = tokens.value
        .where((token) => token.pinnedTime != null)
        .toList()
      ..sort((a, b) => b.pinnedTime!.compareTo(a.pinnedTime!));
    final unpinnedTokens = tokens.value
        .where((token) => token.pinnedTime == null)
        .toList()
      ..sort((a, b) => a.createdAt?.compareTo(b.createdAt ?? DateTime(0)) ?? 0);
    return pinnedTokens..addAll(unpinnedTokens);
  }

  // 更新 tokens 列表
  void setTokens(List<OTPToken> newTokens) {
    tokens.value = newTokens;
  }

  // 添加单个 token
  List<OTPToken> addToken(OTPToken token) {
    final updatedTokens = List<OTPToken>.from(tokens.value)..add(token);
    tokens.value = updatedTokens;
    return updatedTokens;
  }

  // 添加多个 tokens
  List<OTPToken> addTokens(List<OTPToken> newTokens) {
    final updatedTokens = List<OTPToken>.from(tokens.value)..addAll(newTokens);
    tokens.value = updatedTokens;
    return updatedTokens;
  }

  // 删除单个 token
  List<OTPToken> removeToken(String id) {
    final updatedTokens =
        tokens.value.where((token) => token.id != id).toList();
    tokens.value = updatedTokens;
    return updatedTokens;
  }

  // 更新单个 token
  List<OTPToken> updateToken(TokenUpdateRequest updatedToken) {
    final tokenIndex =
        tokens.value.indexWhere((token) => token.id == updatedToken.id);
    if (tokenIndex != -1) {
      final updatedTokens = List<OTPToken>.from(tokens.value);
      final token = updatedTokens[tokenIndex];
      updatedTokens[tokenIndex] = OTPToken(
        id: token.id,
        name: updatedToken.name,
        secret: token.secret,
        issuer: updatedToken.issuer,
        createdAt: token.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: token.deletedAt,
      );
      tokens.value = updatedTokens;
      return updatedTokens;
    }
    return tokens.value;
  }

  // 删除所有 tokens
  List<OTPToken> removeAllTokens() {
    final List<OTPToken> updatedTokens = [];
    tokens.value = updatedTokens;
    return updatedTokens;
  }

  // pin token
  List<OTPToken> pinToken(String id) {
    final updatedTokens = List<OTPToken>.from(tokens.value);
    final token = updatedTokens.firstWhere((token) => token.id == id);
    if (token.pinnedTime != null) {
      token.pinnedTime = null;
      token.updatedAt = DateTime.now();
    } else {
      token.pinnedTime = DateTime.now();
      token.updatedAt = DateTime.now();
    }
    tokens.value = updatedTokens;
    return updatedTokens;
  }

  // 清空所有 tokens
  void clearTokens() {
    tokens.value = [];
  }

  // 根据 ID 获取 token
  OTPToken? getTokenById(String id) {
    return tokens.value.firstWhere(
      (token) => token.id == id,
      orElse: () => OTPToken(
        id: '',
        name: '',
        secret: '',
      ),
    );
  }

  // 获取 tokens 数量
  int get tokenCount => tokens.value.length;

  // 创建 tokens 列表的副本
  List<OTPToken> copyWith({
    List<OTPToken>? tokens,
  }) {
    return tokens ?? List<OTPToken>.from(this.tokens.value);
  }

  // 是否可以添加更多 tokens
  bool get canAddMoreTokens => tokens.value.length < maxAccounts;
}
