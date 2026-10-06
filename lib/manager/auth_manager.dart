import 'package:flutter/foundation.dart';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:two_factor_authentication/config/env_config.dart';
import 'package:two_factor_authentication/services/wechat_login_service.dart';

import '../api/services/auth_service.dart';
import 'storage_manager.dart';
import '../store/user_store.dart';

class AuthManager {
  final AuthService _authService = AuthService();
  final StorageManager _storage = StorageManager();
  final UserStore _userStore = UserStore();

  // 单例模式
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  String? _cachedToken;

  Future<String?> getToken() async {
    if (_cachedToken != null) {
      debugPrint('[AuthManager] 返回缓存的 token');
      return _cachedToken;
    }

    _cachedToken = await _storage.getToken();
    if (_cachedToken != null) {
      debugPrint(
          '[AuthManager] 从 Storage 加载 token，长度: ${_cachedToken!.length}');
    } else {
      debugPrint('[AuthManager] ⚠️ Storage 中没有 token');
    }
    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    _cachedToken = token;
    await _storage.setToken(token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.removeToken();
    _userStore.clearUser();
  }

  Future<bool> isAuthenticated() async {
    return await getToken() != null;
  }

  authenticate() async {
    try {
      // 检查是否已有token
      if (await isAuthenticated()) {
        try {
          // 尝试获取用户信息
          final response = await _authService.getProfile();
          if (response.success && response.data != null) {
            _userStore.setUser(response.data!);
            return response.data;
          }
          // 如果获取失败，清除token
          await clearToken();
          // 继续执行登录流程
        } catch (e) {
          debugPrint('获取用户信息失败: $e');
          await clearToken();
        }
      }

      if (kIsMPFlutterWechat) {
        debugPrint('开始微信登录流程');
        final weChatLoginService = WeChatLoginService();

        debugPrint('获取微信登录码...');
        final weChatCode = await weChatLoginService.getLoginCode();
        debugPrint('已获取微信登录码');

        debugPrint('调用登录接口...');
        final loginResponse = await _authService.login(weChatCode);
        debugPrint('登录响应成功');

        final accessToken = loginResponse.accessToken;
        debugPrint('登录成功，token 长度: ${accessToken.length}');

        await setToken(accessToken);
        debugPrint('✅ Token 已保存到 Storage');

        // 直接使用登录返回的用户信息
        _userStore.setUser(loginResponse.user);
        debugPrint('✅ 用户信息已保存，ID: ${loginResponse.user.id}');
      } else {
        await _storage.setToken(EnvConfig().debugToken);
      }

      try {
        debugPrint('获取用户信息...');
        final userResponse = await _authService.getProfile();
        if (userResponse.success && userResponse.data != null) {
          debugPrint('获取用户信息成功: ${userResponse.data!.nickname}');
          _userStore.setUser(userResponse.data!);
          return userResponse.data;
        }
        debugPrint('获取用户信息失败: ${userResponse.error}');
        return null;
      } catch (e) {
        debugPrint('获取用户信息失败，但保留token: $e');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('登录过程出错:');
      debugPrint('错误: $e');
      debugPrint('堆栈: $stackTrace');
      await clearToken();
      rethrow;
    }
  }

  // 登出
  Future<void> logout() async {
    await clearToken();
  }
}
