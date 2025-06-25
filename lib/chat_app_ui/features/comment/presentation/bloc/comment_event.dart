import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class GetCommentsEvent extends CommentEvent {
  final String storyId;

  const GetCommentsEvent({required this.storyId});

  @override
  List<Object> get props => [storyId];
}

class CreateCommentEvent extends CommentEvent {
  final String storyId;
  final String? parentCommentId;
  final String? content;
  final String? mediaUrl;

  const CreateCommentEvent({
    required this.storyId,
    this.parentCommentId,
    this.content,
    this.mediaUrl,
  });

  @override
  List<Object> get props => [
    storyId,
    parentCommentId ?? '',
    content ?? '',
    mediaUrl ?? '',
  ];
}

class LikeCommentEvent extends CommentEvent {
  final String commentId;

  const LikeCommentEvent({required this.commentId});

  @override
  List<Object> get props => [commentId];
}

class UnlikeCommentEvent extends CommentEvent {
  final String commentId;

  const UnlikeCommentEvent({required this.commentId});

  @override
  List<Object> get props => [commentId];
}

class DeleteCommentEvent extends CommentEvent {
  final String commentId;

  const DeleteCommentEvent({required this.commentId});

  @override
  List<Object> get props => [commentId];
}
