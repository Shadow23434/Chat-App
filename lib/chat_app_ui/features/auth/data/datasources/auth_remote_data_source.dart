import 'dart:convert';
import 'package:chat_app/chat_app_ui/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRemoteDataSource {
  final String baseUrl;

  AuthRemoteDataSource() : baseUrl = dotenv.get('AUTH_URL');

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }

  Future<UserModel> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Signup failed: ${response.body}');
    }

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }

  Future<void> signout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/signout'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Signout failed: ${response.body}');
    }
  }

  Future<UserModel> verifyEmail({required String verificationToken}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-email'),
      body: jsonEncode({'code': verificationToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Verify email failed: ${response.body}');
    }

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }

  Future<void> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Forgot password request failed: ${response.body}');
    }
  }

  Future<UserModel> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password/$token'),
      body: jsonEncode({'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Reset password failed: ${response.body}');
    }

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }
}
