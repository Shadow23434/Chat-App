import 'package:chat_app/chat_app_ui/features/comment/domain/entities/comment_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentsLoaded extends CommentState {
  final List<CommentEntity> comments;

  const CommentsLoaded({required this.comments});

  @override
  List<Object> get props => [comments];
}

class CommentCreated extends CommentState {
  final CommentEntity comment;

  const CommentCreated({required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentLiked extends CommentState {
  final String commentId;
  final int likes;

  const CommentLiked({required this.commentId, required this.likes});

  @override
  List<Object> get props => [commentId, likes];
}

class CommentUnliked extends CommentState {
  final String commentId;
  final int likes;

  const CommentUnliked({required this.commentId, required this.likes});

  @override
  List<Object> get props => [commentId, likes];
}

class CommentDeleted extends CommentState {
  final String commentId;

  const CommentDeleted({required this.commentId});

  @override
  List<Object> get props => [commentId];
}

class CommentFailure extends CommentState {
  final String error;

  const CommentFailure({required this.error});

  @override
  List<Object> get props => [error];
}
