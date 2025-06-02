import 'package:chat_app/core/models/user_model.dart';

class CallModel {
  final String id;
  final UserModel caller;
  final UserModel receiver;
  final String status; // missed, received
  final int duration; // in seconds
  final DateTime startedAt;
  final DateTime? endedAt;

  CallModel({
    required this.id,
    required this.caller,
    required this.receiver,
    required this.status,
    required this.duration,
    required this.startedAt,
    required this.endedAt,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    // Safely access callerId and receiverId, providing a default UserModel if they are null or not a map
    final callerData = json['callerId'];
    final receiverData = json['receiverId'];

    return CallModel(
      id: json['_id'] as String,
      caller:
          (callerData != null && callerData is Map<String, dynamic>)
              ? UserModel.fromJson(callerData)
              : UserModel(
                // Provide default values for UserModel if data is missing
                id: 'unknown',
                username: 'Unknown User',
                email: 'unknown@example.com',
                profilePic: '', // Consider a placeholder image URL
                gender: 'unknown', // Added default gender
                role: 'user', // Added default role
              ),
      receiver:
          (receiverData != null && receiverData is Map<String, dynamic>)
              ? UserModel.fromJson(receiverData)
              : UserModel(
                // Provide default values for UserModel if data is missing
                id: 'unknown',
                username: 'Unknown User',
                email: 'unknown@example.com',
                profilePic: '', // Consider a placeholder image URL
                gender: 'unknown', // Added default gender
                role: 'user', // Added default role
              ),
      status: json['status'] as String,
      duration: json['duration'] as int? ?? 0,
      startedAt: DateTime.parse(json['startedAt'] as String),
      // Safely parse endedAt, allowing it to be null
      endedAt:
          json['endedAt'] != null && json['endedAt'] is String
              ? DateTime.parse(json['endedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'callerId': caller.toJson(),
      'receiverId': receiver.toJson(),
      'status': status,
      'duration': duration,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  // Format duration as minutes and seconds
  String get formattedDuration {
    final minutes = (duration / 60).floor();
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
