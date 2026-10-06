import 'package:flutter/foundation.dart';
import '../api/models/user.dart';
import 'package:intl/intl.dart';

class UserStore {
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;
  UserStore._internal();

  // 使用 ValueNotifier 管理用户信息
  final ValueNotifier<User?> _currentUserNotifier = ValueNotifier<User?>(null);

  // 获取当前用户信息
  User? get currentUser => _currentUserNotifier.value;

  // 获取 ValueNotifier，用于监听用户状态变化
  ValueNotifier<User?> get userNotifier => _currentUserNotifier;

  // 设置当前用户信息
  void setUser(User user) {
    _currentUserNotifier.value = user.copyWith();
  }

  // 清除用户信息
  void clearUser() {
    _currentUserNotifier.value = null;
  }

  // 设置最后同步时间
  void setLastSyncAt(DateTime syncTime) {
    if (_currentUserNotifier.value != null) {
      _currentUserNotifier.value =
          _currentUserNotifier.value!.copyWith(lastSyncAt: syncTime);
    }
  }

  // 设置同步状态
  void setSync(bool syncEnabled) {
    if (_currentUserNotifier.value != null) {
      _currentUserNotifier.value =
          _currentUserNotifier.value!.copyWith(syncEnabled: syncEnabled);
    }
  }

  // 检查是否已登录
  bool get isLoggedIn => _currentUserNotifier.value != null;

  // 获取用户昵称（带默认值）
  String get nickname => _currentUserNotifier.value?.nickname ?? 'Guest';

  // 获取用户邮箱（带默认值）
  String get email => _currentUserNotifier.value?.email ?? '';

  // 获取同步状态
  bool get isSyncEnabled => _currentUserNotifier.value?.syncEnabled ?? false;

  // 获取最后同步时间
  DateTime? get lastSyncTime => _currentUserNotifier.value?.lastSyncAt;

  // 获取格式化的最后同步时间，格式：2023-03-15 10:00
  String? get lastSyncTimeString {
    if (lastSyncTime == null) return null;
    return DateFormat('yyyy-MM-dd HH:mm').format(lastSyncTime!);
  }
}
