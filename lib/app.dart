import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'services/localization_service.dart';
import 'manager/auth_manager.dart';

import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;

class MyAppDelegate {
  late MPFlutterWechatAppDelegate appDelegate;

  MyAppDelegate() {
    appDelegate = MPFlutterWechatAppDelegate(
      onShow: () {
        if (kDebugMode) {
          print("当应用从后台回到前台，被回调。");
        }
      },
      onHide: () {
        if (kDebugMode) {
          print("当应用从前台切到后台，被回调。");
        }
      },
      onShareAppMessage: (detail) {
        if (kDebugMode) {
          print("当用户点击分享给朋友时，回调，应组装对应的 Map 信息，用于展示和回跳。");
        }
        return onShareAppMessage(detail);
      },
      onLaunch: (query, launchptions) async {
        if (kDebugMode) {
          print(launchptions['path']);
          print("应用冷启动时，会收到回调，应根据 query 决定是否要跳转页面。");
        }
        await Future.delayed(
            const Duration(seconds: 1)); // 加个延时，保障 navigator 已初始化。
        onLaunchOrEnter(query);
      },
      onEnter: (query, launchptions) {
        if (kDebugMode) {
          print("应用热启动（例如用户从分享卡片进入小程序）时，会收到回调，应根据 query 决定是否要跳转页面。");
        }
        onLaunchOrEnter(query);
      },
    );
  }

  /// 存在两种返回 Share Info 的方法
  /// - MPFlutterWechatAppShareManager.onShareAppMessage 配合 MPFlutterWechatAppShareManager.setAppShareInfo 使用
  /// - 直接返回符合微信小程序要求的 Map
  Map onShareAppMessage(mpjs.JSObject detail) {
    final currentRoute = MPNavigatorObserver.currentRoute;
    if (currentRoute != null) {
      final routeName = currentRoute.settings.name;
      return {
        "title": "Nice OTP for all platforms",
        "imageUrl": "icon.png",
        "path": "pages/index/index?routeName=$routeName",
      };
    } else {
      return {
        "title": "Nice OTP for all platforms",
        "imageUrl": "icon.png",
      };
    }
  }

  void onLaunchOrEnter(Map query) {
    final navigator = MPNavigatorObserver.currentRoute?.navigator;
    if (navigator != null) {
      final routeName = query["routeName"];
      if (routeName == "/map_demo") {
        navigator.pushNamed("/map_demo");
      }
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 加载语言设置
      final locale = await LanguageService.getSelectedLocale();

      // 进行身份验证
      await AuthManager().authenticate();

      if (mounted) {
        setState(() {
          _locale = locale;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Initialization error: $e');
      }
      // 即使认证失败，也允许应用继续运行
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _handleLocaleChange(Locale newLocale) async {
    await LanguageService.setLocale(newLocale);
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Nice OTP',
      locale: _locale,
      supportedLocales: LanguageService.supportedLocales.values,
      localizationsDelegates: const [
        LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: "MiniTex",
        fontFamilyFallback: const ["MiniTex"],
      ),
      home: HomeScreen(onLocaleChanged: _handleLocaleChange),
    );
  }
}
