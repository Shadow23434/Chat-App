import 'package:chat_app/core/models/user_model.dart';

class MessageModel {
  final String id;
  final String chatId;
  final UserModel sender;
  final String content;
  final String type;
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.type,
    this.mediaUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] as String,
      chatId: json['chatId'] as String,
      sender: UserModel.fromJson(json['senderId'] as Map<String, dynamic>),
      content: json['content'] as String,
      type: json['type'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'senderId': sender.toJson(),
      'content': content,
      'type': type,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
