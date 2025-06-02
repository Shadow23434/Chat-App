import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<List<ChatEntity>> getChats(String userId);
}
