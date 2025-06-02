import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:chat_app/theme.dart';

class ChatStats extends StatelessWidget {
  const ChatStats({
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
    // Calculate percentages
    final totalMsgs = totalMessages > 0 ? totalMessages : 1;
    final textPercentage = (textMessages / totalMsgs) * 100;
    final imagePercentage = (imageMessages / totalMsgs) * 100;
    final audioPercentage = (audioMessages / totalMsgs) * 100;

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: textPercentage,
              radius: 50,
              title: '${textPercentage.toStringAsFixed(0)}%',
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: imagePercentage,
              radius: 50,
              title: '${imagePercentage.toStringAsFixed(0)}%',
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: audioPercentage,
              radius: 50,
              title: '${audioPercentage.toStringAsFixed(0)}%',
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          centerSpaceColor: AppColors.cardView,
        ),
      ),
    );
  }
}
