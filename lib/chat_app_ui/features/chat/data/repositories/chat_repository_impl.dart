import 'package:chat_app/chat_app_ui/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatEntity>> getChats(String userId) async {
    try {
      return await remoteDataSource.getChats(userId);
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }
}
