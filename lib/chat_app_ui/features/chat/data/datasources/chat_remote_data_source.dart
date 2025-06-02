import 'package:chat_app/core/config/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/services/uni_services.dart';
import 'package:dio/dio.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatEntity>> getChats(String userId);
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
      return chatsJson.map((json) => ChatEntity.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }
}
