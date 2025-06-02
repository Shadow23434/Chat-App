import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:chat_app/core/models/index.dart';
import '../base/base_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService extends BaseService with ChangeNotifier {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  UserModel? _currentAdmin;
  Map<String, dynamic>? _lastUserStats;

  UserService(this._dio, this._storage);

  UserModel? get currentAdmin => _currentAdmin;
  Map<String, dynamic>? get lastUserStats => _lastUserStats;

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String sort = 'desc',
    String sortField = 'createdAt',
  }) async {
    try {
      // Log request details for debugging
      if (kDebugMode) {
        print('Making request to: ${dio.options.baseUrl}/users');
        print(
          'Query parameters: page=$page, limit=$limit, search=$search, sort=$sort, sortField=$sortField',
        );
      }

      final response = await dio.get(
        '/users',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          'sort': sort,
          'sortField': sortField,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response data type: ${response.data.runtimeType}');
      }

      // Check if response is HTML (common when server returns error page)
      if (response.data is String &&
          response.data.toString().contains('<!DOCTYPE html>')) {
        throw Exception(
          'Server returned HTML instead of JSON. Check your API endpoint and server status.',
        );
      }

      if (response.statusCode == 200) {
        // Validate response structure
        if (response.data is! Map<String, dynamic>) {
          throw Exception(
            'Invalid response format: Expected JSON object but got ${response.data.runtimeType}',
          );
        }

        final data = response.data as Map<String, dynamic>;

        // Check if required fields exist
        if (!data.containsKey('users') ||
            !data.containsKey('stats') ||
            !data.containsKey('pagination')) {
          throw Exception(
            'Invalid response structure: Missing required fields (users, stats, pagination)',
          );
        }

        return data;
      } else {
        String errorMessage = 'Failed to load users: ${response.statusCode}';
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response?.data}');
      }

      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Session expired. Please login again.';
        } else if (e.response!.statusCode == 403) {
          errorMessage = 'Access denied. You don\'t have permission.';
        } else if (e.response!.statusCode == 404) {
          errorMessage =
              'API endpoint not found. Check your server configuration.';
        } else if (e.response!.data is String &&
            e.response!.data.contains('<!DOCTYPE html>')) {
          errorMessage =
              'Server configuration error: API returning HTML instead of JSON';
        } else if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else {
          errorMessage = 'Server error: ${e.response!.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Check if server is running.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('General exception: $e');
      }
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserModel> addUser({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    String? profilePicture,
    required String role,
    required String gender,
  }) async {
    try {
      final response = await dio.post(
        '/users/add',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
          'gender': gender,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (profilePicture != null) 'profile_picture': profilePicture,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 && response.data is Map) {
        // Extract user data from the 'info' field
        final userData = response.data['info'];
        if (userData != null && userData is Map<String, dynamic>) {
          return UserModel.fromJson(userData);
        } else {
          throw Exception(
            'Invalid data format in response: Missing or invalid "info" field',
          );
        }
      } else {
        String errorMessage = 'Failed to add user';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add user';
      if (e.response?.data is Map && e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<UserModel> editUser({
    required String userId,
    String? username,
    String? email,
    String? password,
    String? phoneNumber,
    Uint8List? profilePicBytes,
    String? profilePicFileName,
    String? gender,
    String? role,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (gender != null) 'gender': gender,
        if (role != null) 'role': role,
        if (profilePicBytes != null && profilePicFileName != null)
          'profilePic': MultipartFile.fromBytes(
            profilePicBytes,
            filename: profilePicFileName,
          ),
      });

      final response = await dio.post(
        '/users/edit/$userId',
        data: formData,
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        // Extract user data from the 'info' field
        final userData = response.data['info'];
        if (userData != null && userData is Map<String, dynamic>) {
          return UserModel.fromJson(userData);
        } else {
          throw Exception(
            'Invalid data format in response: Missing or invalid "info" field',
          );
        }
      } else {
        String errorMessage = 'Failed to update user';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update user';
      if (e.response?.data is Map && e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await dio.post(
        '/users/delete/$userId',
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        String errorMessage = 'Failed to delete user';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete user';
      if (e.response?.data is Map && e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
