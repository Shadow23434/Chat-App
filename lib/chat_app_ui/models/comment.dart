import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String? parentCommentId;
  final int likes;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.likes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    content,
    parentCommentId,
    likes,
    createdAt,
  ];
}
