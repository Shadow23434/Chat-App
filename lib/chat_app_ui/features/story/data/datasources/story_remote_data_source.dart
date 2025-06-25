import 'dart:convert';
import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';
import 'package:chat_app/chat_app_ui/features/story/data/models/story_model.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/core/config/index.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoryRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage _storage;
  String? _authToken;

  StoryRemoteDataSource({http.Client? client})
    : baseUrl = '${Config.apiUrl}/stories',
      client = client ?? http.Client(),
      _storage = const FlutterSecureStorage() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _authToken = await _storage.read(key: 'token');
    logger.d(
      'StoryRemoteDataSource: Token loaded: ${_authToken != null ? 'Yes' : 'No'}',
    );
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      logger.d(
        'StoryRemoteDataSource: Using token: ${_authToken!.substring(0, 10)}...',
      );
    } else {
      logger.e('StoryRemoteDataSource: No token available');
    }

    return headers;
  }

  Future<List<StoryEntity>> getStories() async {
    try {
      await _loadToken();

      final response = await client
          .get(Uri.parse('$baseUrl/get'), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e('Get stories request timed out after 30 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final List<dynamic> storiesJson = responseBody['stories'] ?? [];
        return storiesJson.map((json) => StoryModel.fromJson(json)).toList();
      } else {
        logger.e('Get stories failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to get stories');
      }
    } catch (e) {
      logger.e('Failed to get stories: $e');
      throw Exception('Failed to get stories: $e');
    }
  }

  Future<List<StoryEntity>> getOwnStories() async {
    try {
      await _loadToken();

      final response = await client
          .get(Uri.parse('$baseUrl/own'), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e('Get own stories request timed out after 30 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final List<dynamic> storiesJson = responseBody['stories'] ?? [];
        return storiesJson.map((json) => StoryModel.fromJson(json)).toList();
      } else {
        logger.e('Get own stories failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to get own stories');
      }
    } catch (e) {
      logger.e('Failed to get own stories: $e');
      throw Exception('Failed to get own stories: $e');
    }
  }

  Future<StoryEntity> createStory({
    required String caption,
    required String type,
    String? mediaName,
    String? mediaUrl,
    String? backgroundUrl,
  }) async {
    try {
      await _loadToken();

      final response = await client.post(
        Uri.parse('$baseUrl/create'),
        headers: _headers,
        body: jsonEncode({
          'caption': caption,
          'type': type,
          'mediaName': mediaName,
          'mediaUrl': mediaUrl,
          'backgroundUrl': backgroundUrl,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 && responseBody['success'] == true) {
        return StoryModel.fromJson(responseBody['story']);
      } else {
        logger.e('Create story failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to create story');
      }
    } catch (e) {
      logger.e('Failed to create story: $e');
      throw Exception('Failed to create story: $e');
    }
  }

  Future<int> likeStory(String storyId) async {
    try {
      await _loadToken();

      final response = await client.post(
        Uri.parse('$baseUrl/like/$storyId'),
        headers: _headers,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return responseBody['likes'] as int? ?? 0;
      } else {
        logger.e('Like story failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to like story');
      }
    } catch (e) {
      logger.e('Failed to like story: $e');
      throw Exception('Failed to like story: $e');
    }
  }

  Future<int> unlikeStory(String storyId) async {
    try {
      await _loadToken();

      final response = await client.post(
        Uri.parse('$baseUrl/unlike/$storyId'),
        headers: _headers,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return responseBody['likes'] as int? ?? 0;
      } else {
        logger.e('Unlike story failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to unlike story');
      }
    } catch (e) {
      logger.e('Failed to unlike story: $e');
      throw Exception('Failed to unlike story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _loadToken();

      final response = await client.post(
        Uri.parse('$baseUrl/delete/$storyId'),
        headers: _headers,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode != 200 || responseBody['success'] != true) {
        logger.e('Delete story failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to delete story');
      }
      logger.d('Delete story successful');
    } catch (e) {
      logger.e('Failed to delete story: $e');
      throw Exception('Failed to delete story: $e');
    }
  }
}
