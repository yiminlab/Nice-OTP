import '../api/services/otp_token_service.dart';
import '../api/models/otp_token.dart';
import '../api/models/token_update_request.dart';
import '../api/models/token_operation_response.dart';
import '../api/models/sync_response.dart';
import '../api/models/token_restore_response.dart';

class OTPTokenManager {
  final OTPTokenService _otpTokenService = OTPTokenService();

  // 单例模式
  static final OTPTokenManager _instance = OTPTokenManager._internal();
  factory OTPTokenManager() => _instance;
  OTPTokenManager._internal();

  // 同步令牌
  Future<TokenOperationResponse> syncTokens(
      List<OTPToken> tokens, DateTime? lastSyncAt) async {
    try {
      return await _otpTokenService.syncTokens(tokens, lastSyncAt);
    } catch (e) {
      print('同步令牌失败: $e');
      rethrow;
    }
  }

  // 获取所有令牌
  Future<List<OTPToken>> getTokens() async {
    try {
      final response = await _otpTokenService.getTokens();
      return response.tokens;
    } catch (e) {
      print('获取令牌失败: $e');
      rethrow;
    }
  }

  // 创建令牌
  Future<TokenOperationResponse> createTokens(List<OTPToken> tokens) async {
    try {
      return await _otpTokenService.createTokens(tokens);
    } catch (e) {
      print('创建令牌失败: $e');
      rethrow;
    }
  }

  // 更新令牌
  Future<TokenOperationResponse> updateTokens(
      List<TokenUpdateRequest> tokens) async {
    try {
      return await _otpTokenService.updateTokens(tokens);
    } catch (e) {
      print('更新令牌失败: $e');
      rethrow;
    }
  }

  // 删除令牌
  Future<SyncResponse> deleteToken(String id) async {
    try {
      return await _otpTokenService.deleteToken(id);
    } catch (e) {
      print('删除令牌失败: $e');
      rethrow;
    }
  }

  // 获取已删除的令牌
  Future<List<OTPToken>> getDeletedTokens() async {
    try {
      return await _otpTokenService.getDeletedTokens();
    } catch (e) {
      print('获取已删除令牌失败: $e');
      rethrow;
    }
  }

  // 恢复令牌
  Future<TokenRestoreResponse> restoreTokens(List<String> ids) async {
    try {
      return await _otpTokenService.restoreTokens(ids);
    } catch (e) {
      print('恢复令牌失败: $e');
      rethrow;
    }
  }

  // 删除历史记录
  Future<SyncResponse> deleteHistory() async {
    try {
      return await _otpTokenService.deleteHistory();
    } catch (e) {
      print('删除历史记录失败: $e');
      rethrow;
    }
  }
}
