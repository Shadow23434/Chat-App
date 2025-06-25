import 'package:chat_app/chat_app_ui/features/comment/domain/repositories/comment_repository.dart';

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase({required this.repository});

  Future<void> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
