import 'dart:convert';
import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/core/config/index.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';

class AuthRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  AuthRemoteDataSource({http.Client? client})
    : baseUrl = '${Config.apiUrl}/auth',
      client = client ?? http.Client();

  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/login';

      final response = await client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('Login request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return _createUserEntityFromJson(
          responseBody['info'],
          responseBody['token'],
        );
      } else {
        logger.e('Login failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      logger.e('Failed to login: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<UserEntity> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        logger.d('Registration successful: ${responseBody['user']}');
        return _createUserEntityFromJson(
          responseBody['user'],
          responseBody['token'],
        );
      } else {
        logger.e('Registration failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      logger.e('Failed to register: $e');
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> signout() async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        logger.e('Signout failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Signout failed');
      }
      logger.d('Signout successful');
    } catch (e) {
      logger.e('Failed to logout: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  Future<UserEntity> verifyEmail({required String verificationToken}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': verificationToken}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.d('Email verification successful: ${responseBody['user']}');
        return _createUserEntityFromJson(
          responseBody['user'],
          responseBody['token'],
        );
      } else {
        logger.e('Email verification failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      logger.e('Failed to verify email: $e');
      throw Exception('Failed to verify email: $e');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        logger.e('Forgot password request failed: ${responseBody['message']}');
        throw Exception(
          responseBody['message'] ?? 'Password reset request failed',
        );
      }
      logger.d('Forgot password request successful');
    } catch (e) {
      logger.e('Failed to request password reset: $e');
      throw Exception('Failed to request password reset: $e');
    }
  }

  Future<UserEntity> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': password}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.d('Password reset successful: ${responseBody['user']}');
        return _createUserEntityFromJson(
          responseBody['user'],
          responseBody['token'],
        );
      } else {
        logger.e('Password reset failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      logger.e('Failed to reset password: $e');
      throw Exception('Failed to reset password: $e');
    }
  }

  UserEntity _createUserEntityFromJson(
    Map<String, dynamic> userData,
    String? token,
  ) {
    return UserEntity(
      id: userData['_id'] ?? userData['id'] ?? '',
      username: userData['username'] ?? '',
      email: userData['email'] ?? '',
      password: '',
      phoneNumber: userData['phoneNumber'],
      gender: userData['gender'],
      profilePic: userData['profilePic'],
      lastLogin:
          userData['lastLogin'] != null
              ? DateTime.parse(userData['lastLogin'])
              : null,
      token: token,
    );
  }
}
