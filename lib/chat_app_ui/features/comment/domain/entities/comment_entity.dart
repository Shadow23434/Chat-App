class CommentEntity {
  final String id;
  final String userId;
  final String storyId;
  final String? parentCommentId;
  final String? content;
  final String? mediaUrl;
  final int likes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserInfo? user;

  CommentEntity({
    required this.id,
    required this.userId,
    required this.storyId,
    this.parentCommentId,
    this.content,
    this.mediaUrl,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });
}

class UserInfo {
  final String id;
  final String username;
  final String? profilePic;

  UserInfo({required this.id, required this.username, this.profilePic});
}
