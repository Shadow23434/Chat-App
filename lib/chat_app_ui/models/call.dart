import 'package:chat_app/admin_panel_ui/models/users.dart';

class Call {
  final String id;
  final User caller;
  final User receiver;
  final String status;
  final int duration;
  final DateTime startedAt;
  final DateTime endedAt;
  final String roomId;

  Call({
    required this.id,
    required this.caller,
    required this.receiver,
    required this.status,
    required this.duration,
    required this.startedAt,
    required this.endedAt,
    required this.roomId,
  });
}
