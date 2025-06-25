import 'package:chat_app/chat_app_ui/features/comment/domain/entities/comment_entity.dart';
import 'package:chat_app/chat_app_ui/features/comment/domain/repositories/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase({required this.repository});

  Future<List<CommentEntity>> call(String storyId) {
    return repository.getComments(storyId);
  }
}
