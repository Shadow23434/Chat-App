import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/repositories/message_repository.dart';

class GetMessages {
  final MessageRepository repository;

  GetMessages(this.repository);

  Future<List<MessageModel>> call(String chatId) async {
    return await repository.getMessages(chatId);
  }
}
