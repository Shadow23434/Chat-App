import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'chat_stats.dart';
import 'message_type_stats.dart';
import 'activity_metrics.dart';

class ChatAnalytics extends StatelessWidget {
  const ChatAnalytics({
    super.key,
    required this.totalMessages,
    required this.textMessages,
    required this.imageMessages,
    required this.audioMessages,
    required this.totalUnreadMessages,
  });

  final int totalMessages;
  final int textMessages;
  final int imageMessages;
  final int audioMessages;
  final int totalUnreadMessages;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.cardView,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chat Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ChatStats(
                  totalMessages: totalMessages,
                  textMessages: textMessages,
                  imageMessages: imageMessages,
                  audioMessages: audioMessages,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Message Types',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                MessageTypeStats(
                  totalMessages: totalMessages,
                  textMessages: textMessages,
                  imageMessages: imageMessages,
                  audioMessages: audioMessages,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Activity Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ActivityMetrics(
                  totalMessages: totalMessages,
                  totalUnreadMessages: totalUnreadMessages,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
