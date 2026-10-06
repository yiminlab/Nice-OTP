import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart';

class WeChatLoginService {
  // Singleton pattern
  static final WeChatLoginService _instance = WeChatLoginService._internal();
  factory WeChatLoginService() => _instance;
  WeChatLoginService._internal();

  Future<String> getLoginCode() async {
    try {
      final completer = Completer<String>();

      wx.login(LoginOption()
        ..success = (result) {
          completer.complete(result.code);
        }
        ..fail = (error) {
          completer.completeError(error);
        });

      return await completer.future;
    } catch (e) {
      debugPrint('Failed to get login code: $e');
      rethrow;
    }
  }
}
