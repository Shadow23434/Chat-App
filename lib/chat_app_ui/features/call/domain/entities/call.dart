import 'package:equatable/equatable.dart';

class CallEntity extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String participantProfilePic;
  final String status;
  final DateTime endedAt;

  const CallEntity({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantProfilePic,
    required this.status,
    required this.endedAt,
  });

  @override
  List<Object?> get props => [
    id,
    participantId,
    participantName,
    participantProfilePic,
    status,
    endedAt,
  ];
}
