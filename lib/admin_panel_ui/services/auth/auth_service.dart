import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:chat_app/core/models/index.dart';
import '../base/base_service.dart';

class AuthService extends BaseService with ChangeNotifier {
  UserModel? _currentAdmin;

  UserModel? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;

  Future<void> initializeAuth() async {
    try {
      final token = await getToken();
      final adminJson = await storage.read(key: 'admin');

      if (token != null && adminJson != null) {
        try {
          _currentAdmin = UserModel.fromJson(jsonDecode(adminJson));
        } catch (e) {
          await clearToken();
          await storage.delete(key: 'admin');
          _currentAdmin = null;
        }
      } else {}
    } catch (e) {
      _currentAdmin = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data;
        if (data['success'] == true) {
          await setToken(data['token']);
          final adminData = data['info'];
          _currentAdmin = UserModel.fromJson(adminData);

          await storage.write(key: 'admin', value: jsonEncode(adminData));

          notifyListeners();
          return true;
        }
      }

      final error = response.data['message'] ?? 'Failed to login';
      throw Exception(error);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await dio.post(
          '/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => status! < 500,
          ),
        );
      }

      _currentAdmin = null;
      await clearToken();
      await storage.delete(key: 'admin');

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
