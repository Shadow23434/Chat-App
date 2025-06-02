import 'package:chat_app/core/models/index.dart';
import 'package:dio/dio.dart';
import '../base/base_service.dart';
import 'dart:typed_data';

class ChatService extends BaseService {
  Future<Map<String, dynamic>> getChats({
    int page = 1,
    int limit = 20,
    String search = '',
    String sort = 'desc',
  }) async {
    try {
      print(
        'Searching chats with params: page=$page, limit=$limit, search="$search", sort=$sort',
      );

      final response = await dio.get(
        '/chats',
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search.trim(),
          'sort': sort,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Search response: ${data['chats']?.length ?? 0} chats found');

        return {
          'chats':
              (data['chats'] as List)
                  .map((chat) {
                    try {
                      return ChatModel.fromJson(chat);
                    } catch (e) {
                      print(
                        'Error parsing chat model: $e. Skipping chat: $chat',
                      );
                      return null; // Return null for failed parsing
                    }
                  })
                  .where(
                    (chat) => chat != null,
                  ) // Filter out nulls (failed parses)
                  .toList(),
          'stats': data['stats'],
          'pagination': data['pagination'],
        };
      } else {
        final errorBody = response.data ?? 'No response body';
        print('Search error: Status ${response.statusCode}, Body: $errorBody');
        throw Exception(
          'Failed to load chats: Status code ${response.statusCode}, Body: $errorBody',
        );
      }
    } catch (e) {
      print('Search exception: $e');
      if (e is DioException) {
        throw Exception(
          'Failed to load chats: DioError - ${e.message}, Response: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Failed to load chats hi: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getChatDetails(String chatId) async {
    try {
      final response = await dio.get('/chats/$chatId');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'messages':
              (data['messages'] as List)
                  .map((message) => MessageModel.fromJson(message))
                  .toList(),
          'pagination': data['pagination'],
        };
      } else {
        final errorBody = response.data ?? 'No response body';
        throw Exception(
          'Failed to load chat details: Status code ${response.statusCode}, Body: $errorBody',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Failed to load chat details: DioError - ${e.message}, Response: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Failed to load chat details: $e');
      }
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      final response = await dio.post('/chats/delete/$chatId');

      if (response.statusCode != 200) {
        final errorBody = response.data ?? 'No response body';
        throw Exception(
          'Failed to delete chat: Status code ${response.statusCode}, Body: $errorBody',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Failed to delete chat: DioError - ${e.message}, Response: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Failed to delete chat: $e');
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final response = await dio.post('/messages/delete/$messageId');

      if (response.statusCode != 200) {
        final errorBody = response.data ?? 'No response body';
        throw Exception(
          'Failed to delete message: Status code ${response.statusCode}, Body: $errorBody',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Failed to delete message: DioError - ${e.message}, Response: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Failed to delete message: $e');
      }
    }
  }

  Future<Uint8List> downloadChat(String chatId) async {
    try {
      final response = await dio.get(
        '/chats/download/$chatId',
        options: Options(
          responseType: ResponseType.bytes,
        ), // Important for downloading files
      );

      if (response.statusCode == 200) {
        return response
            .data; // Assuming response.data is Uint8List when responseType is bytes
      } else {
        final errorBody = response.data ?? 'No response body';
        throw Exception(
          'Failed to download chat ID $chatId: Status code ${response.statusCode}, Body: ${String.fromCharCodes(errorBody)}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        // Attempt to read error body if available and it's not a simple connection error
        String errorMessage = e.message ?? 'Unknown Dio error';
        if (e.response?.data != null) {
          try {
            // Assuming the error body might be a string or bytes
            errorMessage =
                '${e.response?.statusCode}: ${String.fromCharCodes(e.response!.data)}';
          } catch (formatError) {
            errorMessage =
                '${e.response?.statusCode}: Failed to parse error body';
          }
        }
        throw Exception(
          'Failed to download chat $chatId: DioError - $errorMessage',
        );
      } else {
        throw Exception('Failed to download chat $chatId: $e');
      }
    }
  }

  Future<Uint8List> downloadAllChats() async {
    try {
      final response = await dio.get(
        '/chats/download-all',
        options: Options(
          responseType: ResponseType.bytes,
        ), // Important for downloading files
      );

      if (response.statusCode == 200) {
        return response.data; // Assuming response.data is Uint8List
      } else {
        final errorBody = response.data ?? 'No response body';
        throw Exception(
          'Failed to download all chats: Status code ${response.statusCode}, Body: ${String.fromCharCodes(errorBody)}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        String errorMessage = e.message ?? 'Unknown Dio error';
        if (e.response?.data != null) {
          try {
            errorMessage =
                '${e.response?.statusCode}: ${String.fromCharCodes(e.response!.data)}';
          } catch (formatError) {
            errorMessage =
                '${e.response?.statusCode}: Failed to parse error body';
          }
        }
        throw Exception(
          'Failed to download all chats: DioError - $errorMessage',
        );
      } else {
        throw Exception('Failed to download all chats: $e');
      }
    }
  }
}
