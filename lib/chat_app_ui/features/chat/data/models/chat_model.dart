import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantId,
    required super.participantName,
    required super.participantProfilePic,
    required super.participantLastLogin,
    required super.lastMessage,
    super.lastMessageAt,
    required super.isRead,
    required super.createdAt,
    required super.lastMessageSenderId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Safely parse all fields, providing defaults for potential nulls.
    final createdAtString = json['created_at'] as String?;
    return ChatModel(
      id: json['_id'] as String? ?? '',
      participantId: json['participant_id'] as String? ?? '',
      participantName: json['participant_name'] as String? ?? '',
      participantProfilePic: json['participant_profile_pic'] as String? ?? '',
      participantLastLogin: json['participant_last_login'],
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageAt:
          json['last_message_at'] != null
              ? DateTime.parse(json['last_message_at'] as String)
              : null,
      isRead: json['is_read'] as bool? ?? false,
      createdAt:
          createdAtString != null
              ? DateTime.parse(createdAtString)
              : DateTime.now(),
      lastMessageSenderId: json['last_message_sender_id'] as String? ?? '',
    );
  }
}
