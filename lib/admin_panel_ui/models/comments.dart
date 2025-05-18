import 'package:chat_app/admin_panel_ui/models/users.dart';

class Comment {
  final String id;
  final String storyId;
  final String? parentCommentId;
  final String content;
  final DateTime createdAt;
  final int likes;
  final String userId;
  User? user;

  Comment({
    required this.id,
    required this.storyId,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.userId,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id']['\$oid'],
      storyId: json['storyId']['\$oid'],
      parentCommentId:
          json['parentCommentId'] != null
              ? json['parentCommentId']['\$oid']
              : null,
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']['\$date']),
      likes: json['likes'],
      userId: json['userId']['\$oid'],
    );
  }
}
