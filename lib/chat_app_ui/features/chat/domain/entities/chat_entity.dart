import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantProfilePic;
  final DateTime participantLastLogin;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final bool isRead;
  final DateTime createdAt;
  final String lastMessageSenderId;

  const ChatEntity({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantProfilePic,
    required this.participantLastLogin,
    required this.lastMessage,
    this.lastMessageAt,
    required this.isRead,
    required this.createdAt,
    required this.lastMessageSenderId,
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
    lastMessageSenderId,
  ];

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    print('ChatEntity: Parsing JSON: $json');
    try {
      // Xử lý cho response từ /chats/create
      final isCreateChat =
          json.containsKey('participantOneId') &&
          json.containsKey('participantTwoId');
      return ChatEntity(
        id: json['_id'] as String? ?? '',
        participantId:
            isCreateChat
                ? (json['participantOneId'] as String? ??
                    json['participantTwoId'] as String? ??
                    '')
                : json['participant_id'] as String? ?? '',
        participantName: json['participant_name'] as String? ?? '',
        participantProfilePic: json['participant_profile_pic'] as String? ?? '',
        participantLastLogin:
            DateTime.tryParse(
              json['participant_last_login'] as String? ?? '',
            ) ??
            DateTime.now(),
        lastMessage: json['last_message'] as String? ?? '',
        lastMessageAt:
            json['last_message_at'] != null &&
                    json['last_message_at'] is String &&
                    (json['last_message_at'] as String).isNotEmpty
                ? DateTime.tryParse(json['last_message_at'] as String)
                : null,
        isRead: json['is_read'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(
              json['createdAt'] as String? ??
                  json['created_at'] as String? ??
                  '',
            ) ??
            DateTime.now(),
        lastMessageSenderId: json['last_message_sender_id'] as String? ?? '',
      );
    } catch (e) {
      print('ChatEntity: Error parsing JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantProfilePic': participantProfilePic,
      'participantLastLogin': participantLastLogin,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
    };
  }
}
