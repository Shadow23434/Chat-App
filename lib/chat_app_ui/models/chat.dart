import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:chat_app/chat_app_ui/models/models.dart';

class Chat {
  final String id;
  final List<User> participants;
  final List<Message> messages;

  Chat({required this.id, required this.participants, required this.messages});
}
