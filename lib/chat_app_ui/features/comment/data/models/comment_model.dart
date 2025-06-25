import 'package:chat_app/chat_app_ui/features/comment/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    required super.id,
    required super.userId,
    required super.storyId,
    super.parentCommentId,
    super.content,
    super.mediaUrl,
    required super.likes,
    required super.createdAt,
    required super.updatedAt,
    super.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Handle userId which can be either a string or a populated object
    String userId;
    UserInfo? user;

    if (json['userId'] is Map<String, dynamic>) {
      // userId is a populated object
      final userObj = json['userId'] as Map<String, dynamic>;
      userId = userObj['_id'] as String? ?? '';
      user = UserInfo(
        id: userObj['_id'] as String? ?? '',
        username: userObj['username'] as String? ?? '',
        profilePic: userObj['profilePic'] as String?,
      );
    } else {
      // userId is a string
      userId = json['userId'] as String? ?? '';
      user = null;
    }

    return CommentModel(
      id: json['_id'] as String? ?? '',
      userId: userId,
      storyId: json['storyId'] as String? ?? '',
      parentCommentId: json['parentCommentId'] as String?,
      content: json['content'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'storyId': storyId,
      'parentCommentId': parentCommentId,
      'content': content,
      'mediaUrl': mediaUrl,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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

  CommentModel copyWith({
    String? id,
    String? userId,
    String? storyId,
    String? parentCommentId,
    String? content,
    String? mediaUrl,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserInfo? user,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storyId: storyId ?? this.storyId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
