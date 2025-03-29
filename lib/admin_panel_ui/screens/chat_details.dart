import 'package:flutter/material.dart';
import 'package:chat_app/admin_panel_ui/models/chats.dart';

class ChatDetails extends StatelessWidget {
  final Chat chat;

  const ChatDetails({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chat.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(chat.avatarUrl),
                  radius: 30,
                ),
                SizedBox(width: 16),
                Text(
                  chat.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Last Message:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(chat.lastMessage),
            SizedBox(height: 20),
            Text(
              'Timestamp:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(chat.timestamp),
          ],
        ),
      ),
    );
  }
}
