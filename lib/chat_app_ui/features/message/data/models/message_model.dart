import 'package:chat_app/chat_app_ui/features/message/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.content,
    required super.type,
    required super.mediaUrl,
    required super.isRead,
    required super.createdAt,
    super.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final createdAtString = json['created_at'] as String?;
    final updatedAtString = json['updated_at'] as String?;

    return MessageModel(
      id: json['_id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt:
          createdAtString != null
              ? DateTime.parse(createdAtString)
              : DateTime.now(),
      updatedAt:
          updatedAtString != null ? DateTime.parse(updatedAtString) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'media_url': mediaUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
