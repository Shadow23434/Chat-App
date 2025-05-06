import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required super.id,
    required super.participantName,
    required super.participantProfilePic,
    required super.lastMessage,
    required super.lastMessageAt,
    required super.isRead,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'],
      participantName: json['participant_name'],
      participantProfilePic: json['participant_profile_pic'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'],
      isRead: json['is_read'],
    );
  }
}
