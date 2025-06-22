import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String type;
  final String mediaUrl;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.mediaUrl,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    content,
    type,
    mediaUrl,
    isRead,
    createdAt,
    updatedAt,
  ];
}
