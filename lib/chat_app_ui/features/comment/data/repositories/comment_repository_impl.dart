import 'package:chat_app/chat_app_ui/features/comment/domain/entities/comment_entity.dart';
import 'package:chat_app/chat_app_ui/features/comment/domain/repositories/comment_repository.dart';
import 'package:chat_app/chat_app_ui/features/comment/data/datasources/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommentEntity>> getComments(String storyId) async {
    try {
      final comments = await remoteDataSource.getComments(storyId);
      return comments;
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  @override
  Future<CommentEntity> createComment({
    required String storyId,
    String? parentCommentId,
    String? content,
    String? mediaUrl,
  }) async {
    try {
      final comment = await remoteDataSource.createComment(
        storyId: storyId,
        parentCommentId: parentCommentId,
        content: content,
        mediaUrl: mediaUrl,
      );
      return comment;
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  @override
  Future<int> likeComment(String commentId) async {
    try {
      final likes = await remoteDataSource.likeComment(commentId);
      return likes;
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  @override
  Future<int> unlikeComment(String commentId) async {
    try {
      final likes = await remoteDataSource.unlikeComment(commentId);
      return likes;
    } catch (e) {
      throw Exception('Failed to unlike comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
