import 'dart:convert';
import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/core/config/index.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CallRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage _storage;
  String? _authToken;

  CallRemoteDataSource({http.Client? client})
    : baseUrl = '${Config.apiUrl}/calls',
      client = client ?? http.Client(),
      _storage = const FlutterSecureStorage();

  Future<void> _loadToken() async {
    _authToken = await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    // Ensure token is loaded
    if (_authToken == null) {
      await _loadToken();
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<List<CallEntity>> getCalls() async {
    try {
      final url = '$baseUrl/get';
      final headers = await _getHeaders();

      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('Get calls request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = responseBody;
        return jsonList.map((json) => _createCallEntityFromJson(json)).toList();
      } else if (response.statusCode == 401) {
        logger.e('Authentication failed: No valid token');
        throw Exception('Authentication failed. Please login again.');
      } else {
        logger.e('Get calls failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to get calls');
      }
    } catch (e) {
      logger.e('Failed to get calls: $e');
      throw Exception('Failed to get calls: $e');
    }
  }

  Future<CallEntity> createCall({
    required String participantId,
    required String callType, // 'audio' or 'video'
  }) async {
    try {
      final url = '$baseUrl/create';
      final headers = await _getHeaders();

      final response = await client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({
              'participantId': participantId,
              'callType': callType,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('Create call request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        logger.d('Call created successfully: ${responseBody['call']}');
        return _createCallEntityFromJson(responseBody['call']);
      } else if (response.statusCode == 401) {
        logger.e('Authentication failed: No valid token');
        throw Exception('Authentication failed. Please login again.');
      } else {
        logger.e('Create call failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to create call');
      }
    } catch (e) {
      logger.e('Failed to create call: $e');
      throw Exception('Failed to create call: $e');
    }
  }

  Future<void> endCall({
    required String callId,
    required String status, // 'completed', 'missed', 'declined'
  }) async {
    try {
      final url = '$baseUrl/$callId/end';
      final headers = await _getHeaders();

      final response = await client
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('End call request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (response.statusCode == 200) {
        logger.d('Call ended successfully');
      } else if (response.statusCode == 401) {
        logger.e('Authentication failed: No valid token');
        throw Exception('Authentication failed. Please login again.');
      } else {
        final responseBody = jsonDecode(response.body);
        logger.e('End call failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to end call');
      }
    } catch (e) {
      logger.e('Failed to end call: $e');
      throw Exception('Failed to end call: $e');
    }
  }

  Future<void> answerCall({required String callId}) async {
    try {
      final url = '$baseUrl/$callId/answer';
      final headers = await _getHeaders();

      final response = await client
          .put(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('Answer call request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (response.statusCode == 200) {
        logger.d('Call answered successfully');
      } else if (response.statusCode == 401) {
        logger.e('Authentication failed: No valid token');
        throw Exception('Authentication failed. Please login again.');
      } else {
        final responseBody = jsonDecode(response.body);
        logger.e('Answer call failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to answer call');
      }
    } catch (e) {
      logger.e('Failed to answer call: $e');
      throw Exception('Failed to answer call: $e');
    }
  }

  Future<void> declineCall({required String callId}) async {
    try {
      final url = '$baseUrl/$callId/decline';
      final headers = await _getHeaders();

      final response = await client
          .put(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('Decline call request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (response.statusCode == 200) {
        logger.d('Call declined successfully');
      } else if (response.statusCode == 401) {
        logger.e('Authentication failed: No valid token');
        throw Exception('Authentication failed. Please login again.');
      } else {
        final responseBody = jsonDecode(response.body);
        logger.e('Decline call failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to decline call');
      }
    } catch (e) {
      logger.e('Failed to decline call: $e');
      throw Exception('Failed to decline call: $e');
    }
  }

  CallEntity _createCallEntityFromJson(Map<String, dynamic> callData) {
    return CallEntity(
      id: callData['_id'] ?? callData['id'] ?? '',
      participantId:
          callData['partipant_id'] ?? callData['participantId'] ?? '',
      participantName:
          callData['partipant_name'] ?? callData['participantName'] ?? '',
      participantProfilePic:
          callData['partipant_profile_pic'] ??
          callData['participantProfilePic'] ??
          '',
      status: callData['status'] ?? '',
      endedAt:
          callData['endedAt'] != null
              ? DateTime.parse(callData['endedAt'])
              : DateTime.now(),
    );
  }
}
