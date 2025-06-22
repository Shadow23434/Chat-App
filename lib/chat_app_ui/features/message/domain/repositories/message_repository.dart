import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';

abstract class MessageRepository {
  Future<List<MessageModel>> getMessages(String chatId);
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    required String type,
    String? mediaUrl,
  });
}
