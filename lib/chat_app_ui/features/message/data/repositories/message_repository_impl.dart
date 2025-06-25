import 'package:chat_app/chat_app_ui/features/message/data/datasources/message_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;

  MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      return await remoteDataSource.getMessages(chatId);
    } catch (e) {
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
      return await remoteDataSource.sendMessage(
        chatId: chatId,
        content: content,
        type: type,
        mediaUrl: mediaUrl,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
