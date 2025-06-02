import 'package:chat_app/chat_app_ui/services/context_utility.dart';
import 'package:chat_app/chat_app_ui/services/green.dart';
import 'package:chat_app/chat_app_ui/services/red.dart';
import 'package:chat_app/core/config/index.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class UniServices {
  static String? _code;
  static String? get code => _code;
  static void setCode(String value) => _code = value;
  static void reset() => _code = '';

  static late Dio dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: Config.apiUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
  }

  static uniHandler(Uri? uri) {
    if (uri == null || uri.queryParameters.isEmpty) return;

    Map<String, dynamic> param = uri.queryParameters;
    String receivedCode = param['code'] ?? '';

    if (receivedCode == 'green') {
      Navigator.push(
        ContextUtility.context!,
        MaterialPageRoute(builder: (_) => GreenScreen()),
      );
    } else {
      Navigator.push(
        ContextUtility.context!,
        MaterialPageRoute(builder: (_) => RedScreen()),
      );
    }
  }
}
