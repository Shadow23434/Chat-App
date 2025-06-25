import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_app/core/config/index.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/chat_app_ui/features/comment/data/models/comment_model.dart';

class CommentRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage _storage;
  String? _authToken;

  CommentRemoteDataSource({http.Client? client})
    : baseUrl = '${Config.apiUrl}/comments',
      client = client ?? http.Client(),
      _storage = const FlutterSecureStorage() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _authToken = await _storage.read(key: 'auth_token');
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<List<CommentModel>> getComments(String storyId) async {
    try {
      final url = '$baseUrl/get/$storyId';

      final response = await client
          .get(Uri.parse(url), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e('Get comments request timed out after 30 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> commentsJson = responseBody['comments'] ?? [];
        return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        logger.e('Get comments failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to get comments');
      }
    } catch (e) {
      logger.e('Failed to get comments: $e');
      throw Exception('Failed to get comments: $e');
    }
  }

  Future<CommentModel> createComment({
    required String storyId,
    String? parentCommentId,
    String? content,
    String? mediaUrl,
  }) async {
    try {
      final url = '$baseUrl/create';

      final body = {
        'storyId': storyId,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
        if (content != null) 'content': content,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      };

      final response = await client
          .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              logger.e('Create comment request timed out after 60 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        logger.d('Comment created successfully: ${responseBody['comment']}');
        return CommentModel.fromJson(responseBody['comment']);
      } else {
        logger.e('Create comment failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to create comment');
      }
    } catch (e) {
      logger.e('Failed to create comment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<int> likeComment(String commentId) async {
    try {
      final url = '$baseUrl/like/$commentId';

      final response = await client
          .post(Uri.parse(url), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e('Like comment request timed out after 30 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.d('Comment liked successfully: ${responseBody['likes']}');
        return responseBody['likes'] as int;
      } else {
        logger.e('Like comment failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to like comment');
      }
    } catch (e) {
      logger.e('Failed to like comment: $e');
      throw Exception('Failed to like comment: $e');
    }
  }

  Future<int> unlikeComment(String commentId) async {
    try {
      final url = '$baseUrl/unlike/$commentId';

      final response = await client
          .post(Uri.parse(url), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e('Unlike comment request timed out after 30 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.d('Comment unliked successfully: ${responseBody['likes']}');
        return responseBody['likes'] as int;
      } else {
        logger.e('Unlike comment failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to unlike comment');
      }
    } catch (e) {
      logger.e('Failed to unlike comment: $e');
      throw Exception('Failed to unlike comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final url = '$baseUrl/delete/$commentId';

      final response = await client
          .delete(Uri.parse(url), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logger.e('Delete comment request timed out after 30 seconds');
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (response.statusCode == 200) {
        logger.d('Comment deleted successfully');
      } else {
        final responseBody = jsonDecode(response.body);
        logger.e('Delete comment failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to delete comment');
      }
    } catch (e) {
      logger.e('Failed to delete comment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }
}
