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
    final createdAtString = json['createdAt'] as String?;
    final updatedAtString = json['updatedAt'] as String?;

    return MessageModel(
      id: json['_id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
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
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
