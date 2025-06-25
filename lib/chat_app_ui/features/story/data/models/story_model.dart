import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';

class StoryModel extends StoryEntity {
  StoryModel({
    required super.id,
    required super.userId,
    super.caption,
    required super.type,
    super.backgroundUrl,
    super.mediaName,
    super.mediaUrl,
    required super.createdAt,
    required super.expiresAt,
    required super.likes,
    super.user,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id'] as String? ?? '',
      userId:
          json['userId'] is Map
              ? json['userId']['_id'] as String? ?? ''
              : json['userId'] as String? ?? '',
      caption: json['caption'] as String?,
      type: json['type'] as String? ?? '',
      backgroundUrl: json['backgroundUrl'] as String?,
      mediaName: json['mediaName'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : DateTime.now().add(const Duration(hours: 24)),
      likes: json['likes'] as int? ?? 0,
      user:
          json['userId'] is Map
              ? UserInfo(
                id: json['userId']['_id'] as String? ?? '',
                username: json['userId']['username'] as String? ?? '',
                profilePic: json['userId']['profilePic'] as String?,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'caption': caption,
      'type': type,
      'backgroundUrl': backgroundUrl,
      'mediaName': mediaName,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'likes': likes,
      'user':
          user != null
              ? {
                '_id': user!.id,
                'username': user!.username,
                'profilePic': user!.profilePic,
              }
              : null,
    };
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? caption,
    String? type,
    String? backgroundUrl,
    String? mediaName,
    String? mediaUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? likes,
    UserInfo? user,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      type: type ?? this.type,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      mediaName: mediaName ?? this.mediaName,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      likes: likes ?? this.likes,
      user: user ?? this.user,
    );
  }
}
