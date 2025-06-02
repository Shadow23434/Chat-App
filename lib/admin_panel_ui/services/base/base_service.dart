import 'dart:convert';
import 'package:chat_app/core/config/index.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

abstract class BaseService {
  final String baseUrl;
  final http.Client client;
  late final Dio _dio;
  final storage = const FlutterSecureStorage();
  String? _token;

  BaseService({http.Client? client})
    : baseUrl = Config.apiUrl,
      client = client ?? http.Client() {
    final adminApiUrl = '${Config.apiUrl}/admin';

    if (kDebugMode) {
      print('Initializing BaseService with Admin API URL: $adminApiUrl');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: adminApiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept status codes less than 500 (including 4xx errors)
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print(
              '🚀 REQUEST: ${options.method} ${options.baseUrl}${options.path}',
            );
            print('Headers: ${options.headers}');
            print('Query Parameters: ${options.queryParameters}');
            if (options.data != null) {
              print('Data: ${options.data}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '✅ RESPONSE: ${response.statusCode} ${response.statusMessage}',
            );
            print('Response Headers: ${response.headers}');
            print('Response Data Type: ${response.data.runtimeType}');

            // Log first 500 characters of response data for debugging
            final dataStr = response.data.toString();
            if (dataStr.length > 500) {
              print(
                'Response Data (first 500 chars): ${dataStr.substring(0, 500)}...',
              );
            } else {
              print('Response Data: $dataStr');
            }
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            print('❌ ERROR: ${error.type}');
            print('Error Message: ${error.message}');
            print('Response Status: ${error.response?.statusCode}');
            print('Response Data: ${error.response?.data}');
          }

          // Handle specific error cases
          if (error.response?.statusCode == 401) {
            // Token expired, clear it
            await clearToken();
          }

          return handler.next(error);
        },
      ),
    );

    // Enable logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            print('[DIO LOG] $obj');
          },
        ),
      );
    }
  }

  // Helper function for safely decoding JSON
  Map<String, dynamic> _safeJsonDecode(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('JSON decode error: $e');
        print('Body content: $body');
      }
      return {};
    }
  }

  // Helper method to get headers with auth token
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Get auth token
  Future<String?> getToken() async {
    _token = await storage.read(key: 'accessToken');
    if (kDebugMode && _token != null) {
      print('Token retrieved: ${_token!.substring(0, 20)}...');
    }
    return _token;
  }

  // Set auth token
  Future<void> setToken(String token) async {
    _token = token;
    await storage.write(key: 'accessToken', value: token);
    if (kDebugMode) {
      print('Token saved: ${token.substring(0, 20)}...');
    }
  }

  // Clear auth token
  Future<void> clearToken() async {
    _token = null;
    await storage.delete(key: 'accessToken');
    if (kDebugMode) {
      print('Token cleared');
    }
  }

  // Get Dio instance
  Dio get dio => _dio;
}
