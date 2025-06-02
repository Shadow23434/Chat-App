import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({
    super.key,
    required this.onDownload,
    required this.onRefresh,
  });

  final VoidCallback onDownload;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Chats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Row(
              children: [
                IconNoBorder(icon: Icons.download, onTap: onDownload),
                const SizedBox(width: 8),
                IconNoBorder(icon: Icons.refresh, onTap: onRefresh),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
