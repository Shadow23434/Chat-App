class StoryEntity {
  final String id;
  final String userId;
  final String? caption;
  final String type;
  final String? backgroundUrl;
  final String? mediaName;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int likes;
  final UserInfo? user;

  StoryEntity({
    required this.id,
    required this.userId,
    this.caption,
    required this.type,
    this.backgroundUrl,
    this.mediaName,
    this.mediaUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.likes,
    this.user,
  });
}

class UserInfo {
  final String id;
  final String username;
  final String? profilePic;

  UserInfo({required this.id, required this.username, this.profilePic});
}
