import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_factor_authentication/api/models/otp_token.dart';

class StorageManager {
  static const String _tokenKey = 'auth_token';
  static const String _accountsKey = 'otp_accounts';
  static const String _pinnedKey = 'pinned_accounts';
  static const String _lastSyncAtKey = 'last_sync_at';

  static final StorageManager _instance = StorageManager._internal();
  factory StorageManager() => _instance;
  StorageManager._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Auth Token 相关方法
  Future<String?> getToken() async {
    await init();
    return _prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    await init();
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> removeToken() async {
    await init();
    await _prefs.remove(_tokenKey);
  }

  Future<List<OTPToken>> getAccounts() async {
    await init();
    final String? encodedData = _prefs.getString(_accountsKey);
    if (encodedData == null) {
      return [];
    }
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => OTPToken.fromJson(item)).toList();
  }

  Future<void> setAccounts(List<OTPToken> accounts) async {
    await init();
    final String encodedData =
        json.encode(accounts.map((account) => account.toJson()).toList());
    await _prefs.setString(_accountsKey, encodedData);
  }

  // Pinned Accounts 相关方法
  Future<List<String>> getPinnedAccounts() async {
    await init();
    return _prefs.getStringList(_pinnedKey) ?? [];
  }

  Future<void> setPinnedAccounts(List<String> pinnedAccounts) async {
    await init();
    await _prefs.setStringList(_pinnedKey, pinnedAccounts);
  }

  // User 相关方法
  Future<DateTime?> getLastSyncAt() async {
    await init();
    final timestamp = _prefs.getString(_lastSyncAtKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  Future<void> setLastSyncAt(DateTime lastSyncAt) async {
    await init();
    await _prefs.setString(_lastSyncAtKey, lastSyncAt.toIso8601String());
  }

  Future<void> removeLastSyncAt() async {
    await init();
    await _prefs.remove(_lastSyncAtKey);
  }

  // 清除所有数据
  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }
}
