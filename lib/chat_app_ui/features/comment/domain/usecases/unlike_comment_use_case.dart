import 'package:chat_app/chat_app_ui/features/comment/domain/repositories/comment_repository.dart';

class UnlikeCommentUseCase {
  final CommentRepository repository;

  UnlikeCommentUseCase({required this.repository});

  Future<int> call(String commentId) {
    return repository.unlikeComment(commentId);
  }
}
