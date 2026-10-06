import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { dev, prod }

class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  late Environment environment;

  Future<void> initialize(Environment env) async {
    environment = env;
    // 根据环境加载不同的 .env 文件
    await dotenv.load(
        fileName: env == Environment.dev ? '.env.dev' : '.env.prod');
  }

  String get debugToken => dotenv.env['DEBUG_TOKEN'] ?? "";
  String get apiBaseUrl => dotenv.env['apiBaseUrl'] ?? "";
}
