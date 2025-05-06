import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/repositories/chat_repository.dart';

class FetchChatsUseCase {
  final ChatRepository repository;

  FetchChatsUseCase(this.repository);

  Future<List<ChatEntity>> call() async {
    return repository.fetchChats();
  }
}
