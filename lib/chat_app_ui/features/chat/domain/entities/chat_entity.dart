import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantProfilePic;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final bool isRead;
  final DateTime createdAt;

  const ChatEntity({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantProfilePic,
    required this.lastMessage,
    this.lastMessageAt,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    participantId,
    participantName,
    participantProfilePic,
    lastMessage,
    lastMessageAt,
    isRead,
    createdAt,
  ];

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    return ChatEntity(
      id: json['_id'] as String? ?? '',
      participantId: json['participant_id'] as String? ?? '',
      participantName: json['participant_name'] as String? ?? '',
      participantProfilePic: json['participant_profile_pic'] as String? ?? '',
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageAt:
          json['last_message_at'] != null
              ? DateTime.parse(json['last_message_at'] as String)
              : null,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantProfilePic': participantProfilePic,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
