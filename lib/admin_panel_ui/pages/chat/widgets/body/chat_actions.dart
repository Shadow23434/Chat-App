import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';

class ChatActions extends StatelessWidget {
  const ChatActions({
    super.key,
    required this.chat,
    required this.onDelete,
    required this.downloadChatData,
  });

  final ChatModel chat;
  final Function(String) onDelete;
  final Function(ChatModel?) downloadChatData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconNoBorder(
          icon: Icons.visibility,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatDetails(chat: chat)),
            );
          },
        ),
        IconNoBorder(icon: Icons.download, onTap: () => downloadChatData(chat)),
        IconNoBorder(
          icon: Icons.delete_rounded,
          onTap: () => onDelete(chat.id),
        ),
      ],
    );
  }
}
