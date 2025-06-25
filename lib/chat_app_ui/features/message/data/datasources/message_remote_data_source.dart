import 'package:chat_app/core/config/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/services/uni_services.dart';
import 'package:dio/dio.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';

abstract class MessageRemoteDataSource {
  Future<List<MessageModel>> getMessages(String chatId);
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    required String type,
    required String mediaUrl,
  });
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final String baseUrl;
  final _storage = FlutterSecureStorage();

  MessageRemoteDataSourceImpl() : baseUrl = Config.apiUrl;

  String _handleDioError(DioException error) {
    logger.e('DioError: ${error.type} - ${error.message}');
    logger.e('Request URL: ${error.requestOptions.uri}');
    logger.e('Response Status: ${error.response?.statusCode}');
    logger.e('Response Data: ${error.response?.data}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error';

        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access denied: $message';
          case 404:
            return 'Chat not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Error $statusCode: $message';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection.';

      case DioExceptionType.unknown:
        return 'An unexpected error occurred.';

      default:
        return 'Failed to connect to server.';
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final url = '$baseUrl/messages/get/$chatId';
      logger.d('URL: $url');

      final response = await UniServices.dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final List<dynamic> messagesJson = response.data['messages'];

      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      logger.e('Failed to get messages: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Failed to get messages: $e');
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    required String type,
    required String mediaUrl,
  }) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final url = '$baseUrl/messages/save';
      logger.d('Sending message to URL: $url');
      logger.d('Chat ID: $chatId');
      logger.d('Type: $type');
      logger.d('Content: $content');
      logger.d('Media Url: $mediaUrl');

      final response = await UniServices.dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
        data: {
          'chatId': chatId,
          'type': type,
          'content': content,
          'mediaUrl': mediaUrl,
        },
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      logger.d('Message sent successfully');
      return MessageModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      logger.e('Failed to send message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Failed to send message: $e');
      throw Exception('Failed to send message: $e');
    }
  }
}
