import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';

class CallModel extends CallEntity {
  const CallModel({
    required super.id,
    required super.participantId,
    required super.participantName,
    required super.participantProfilePic,
    required super.status,
    required super.endedAt,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['_id'] as String,
      participantId: json['partipant_id'] as String,
      participantName: json['partipant_name'] as String,
      participantProfilePic: json['partipant_profile_pic'] as String,
      status: json['status'] as String,
      endedAt: DateTime.parse(json['endedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'partipant_id': participantId,
      'partipant_name': participantName,
      'partipant_profile_pic': participantProfilePic,
      'status': status,
      'endedAt': endedAt.toIso8601String(),
    };
  }
}
