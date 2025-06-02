import 'package:flutter/material.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';

class MessageTypeStats extends StatelessWidget {
  const MessageTypeStats({
    super.key,
    required this.totalMessages,
    required this.textMessages,
    required this.imageMessages,
    required this.audioMessages,
  });

  final int totalMessages;
  final int textMessages;
  final int imageMessages;
  final int audioMessages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 390,
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final totalMsgs = totalMessages > 0 ? totalMessages : 1;
          switch (index) {
            case 0:
              return ProcessCard(
                title: 'Text',
                subtile: '$textMessages Messages',
                icon: Icons.message,
                value: textMessages / totalMsgs,
                color: Colors.blue,
                hasBorder: true,
              );
            case 1:
              return ProcessCard(
                title: 'Images',
                subtile: '$imageMessages Messages',
                icon: Icons.image,
                value: imageMessages / totalMsgs,
                color: Colors.green,
                hasBorder: true,
              );
            case 2:
              return ProcessCard(
                title: 'Audio',
                subtile: '$audioMessages Messages',
                icon: Icons.mic,
                value: audioMessages / totalMsgs,
                color: Colors.orange,
                hasBorder: true,
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}
