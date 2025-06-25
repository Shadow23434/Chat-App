import 'package:chat_app/chat_app_ui/features/comment/domain/repositories/comment_repository.dart';

class LikeCommentUseCase {
  final CommentRepository repository;

  LikeCommentUseCase({required this.repository});

  Future<int> call(String commentId) {
    return repository.likeComment(commentId);
  }
}
