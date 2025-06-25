import 'package:chat_app/chat_app_ui/features/comment/domain/entities/comment_entity.dart';
import 'package:chat_app/chat_app_ui/features/comment/domain/repositories/comment_repository.dart';

class CreateCommentUseCase {
  final CommentRepository repository;

  CreateCommentUseCase({required this.repository});

  Future<CommentEntity> call({
    required String storyId,
    String? parentCommentId,
    String? content,
    String? mediaUrl,
  }) {
    return repository.createComment(
      storyId: storyId,
      parentCommentId: parentCommentId,
      content: content,
      mediaUrl: mediaUrl,
    );
  }
}
