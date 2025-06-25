import 'package:chat_app/chat_app_ui/features/comment/domain/entities/comment_entity.dart';

abstract class CommentRepository {
  Future<List<CommentEntity>> getComments(String storyId);
  Future<CommentEntity> createComment({
    required String storyId,
    String? parentCommentId,
    String? content,
    String? mediaUrl,
  });
  Future<int> likeComment(String commentId);
  Future<int> unlikeComment(String commentId);
  Future<void> deleteComment(String commentId);
}
