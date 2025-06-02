import 'package:chat_app/core/models/index.dart';

class ChatModel {
  final String id;
  final List<UserModel> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int messageCount;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    required this.messageCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw Exception('Empty JSON data provided to ChatModel.fromJson');
    }

    // Handle MongoDB ObjectId
    String parseId(dynamic id) {
      if (id == null) {
        print('Warning: Chat ID is null in ChatModel.fromJson');
        return '';
      }
      if (id is Map && id.containsKey('\$oid')) {
        return id['\$oid'] as String;
      } else if (id is String) {
        return id;
      } else {
        print('Warning: Unexpected type for Chat ID: ${id.runtimeType}');
        return id.toString();
      }
    }

    // Helper to parse User from participant object
    UserModel? parseParticipant(dynamic participantJson) {
      if (participantJson == null) return null;
      try {
        return UserModel.fromJson(participantJson as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing participant data: $e');
        return null;
      }
    }

    try {
      final participantOne = parseParticipant(json['participantOneId']);
      final participantTwo = parseParticipant(json['participantTwoId']);

      final List<UserModel> participantsList = [];
      if (participantOne != null) participantsList.add(participantOne);
      if (participantTwo != null) participantsList.add(participantTwo);

      return ChatModel(
        id: parseId(json['_id']),
        participants: participantsList,
        lastMessage: json['lastMessage']?.toString(),
        lastMessageAt:
            json['lastMessageAt'] != null
                ? DateTime.parse(json['lastMessageAt'].toString())
                : null,
        messageCount:
            int.tryParse(json['messageCount']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      throw Exception('Error parsing ChatModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((u) => u.toJson()).toList(),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'messageCount': messageCount,
    };
  }
}

class UserInfo {
  final String id;
  final String name;
  final String email;
  final String? profilePic;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw Exception('Empty JSON data provided to UserInfo.fromJson');
    }

    return UserInfo(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      profilePic: json['profilePic']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email, 'profilePic': profilePic};
  }
}
