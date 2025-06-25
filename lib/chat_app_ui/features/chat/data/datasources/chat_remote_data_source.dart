import 'package:chat_app/core/config/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/services/uni_services.dart';
import 'package:dio/dio.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatEntity>> getChats(String userId);
  Future<ChatEntity?> getChatWithUser(String currentUserId, String otherUserId);
  Future<ChatEntity?> createChat(String participantId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final String baseUrl;
  final _storage = FlutterSecureStorage();

  ChatRemoteDataSourceImpl() : baseUrl = '${Config.apiUrl}/chats';

  @override
  Future<List<ChatEntity>> getChats(String userId) async {
    try {
      final token = await _storage.read(key: 'token');
      final response = await UniServices.dio.get(
        '/chats/get',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List<dynamic> chatsJson = response.data;

      // Debug: Log each chat's participant information
      for (int index = 0; index < chatsJson.length; index++) {
        final chatJson = chatsJson[index];
      }

      return chatsJson.map((json) => ChatEntity.fromJson(json)).toList();
    } catch (e) {
      print('ChatRemoteDataSource: Error getting chats: $e');
      throw Exception('Failed to get chats: $e');
    }
  }

  @override
  Future<ChatEntity?> getChatWithUser(
    String currentUserId,
    String otherUserId,
  ) async {
    final chats = await getChats(currentUserId);
    try {
      return chats.firstWhere((chat) => chat.participantId == otherUserId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ChatEntity?> createChat(String participantId) async {
    try {
      final token = await _storage.read(key: 'token');
      final response = await UniServices.dio.post(
        '/chats/create',
        data: {'participantId': participantId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data['success'] == true && data['chat'] != null) {
        return ChatEntity.fromJson(data['chat']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create chat');
      }
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }
}
