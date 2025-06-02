import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
// import 'package:chat_app/core/models/index.dart'; // Remove this import if ChatModel is not used
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';

class ChatCardList extends StatelessWidget {
  const ChatCardList({
    super.key,
    // Remove chats and totalUnreadMessages parameters
    // required this.chats,
    // required this.totalUnreadMessages,
    required this.totalChats, // Add totalChats parameter
    required this.totalMessages, // Add totalMessages parameter
  });

  // Add fields for totalChats and totalMessages
  final int totalChats;
  final int totalMessages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 2,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ProcessCard(
                  title: 'Chats',
                  // Use totalChats for the subtitle
                  subtile: "$totalChats Chats",
                  icon: Icons.chat,
                  value:
                      totalChats > 0
                          ? 1
                          : 0, // Adjust value based on totalChats
                  color: AppColors.secondary,
                );
              case 1:
                // Use the totalMessages parameter directly
                // int totalMessages = chats.fold(
                //   0,
                //   (sum, chat) => sum + chat.messageCount,
                // );
                return ProcessCard(
                  title: 'Messages',
                  // Use totalMessages for the subtitle
                  subtile: "$totalMessages Messages",
                  icon: Icons.message,
                  value:
                      totalMessages > 0
                          ? 1
                          : 0, // Adjust value based on totalMessages
                  color: Colors.blue,
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
