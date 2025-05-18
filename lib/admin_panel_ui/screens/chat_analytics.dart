import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:chat_app/admin_panel_ui/models/chats.dart' as chat_models;
import 'package:chat_app/admin_panel_ui/services/demo_data.dart';

class ChatAnalytics extends StatefulWidget {
  final chat_models.Chat chat;

  const ChatAnalytics({super.key, required this.chat});

  @override
  State<ChatAnalytics> createState() => _ChatAnalyticsState();
}

class _ChatAnalyticsState extends State<ChatAnalytics> {
  final DemoData _demoData = DemoData();
  bool isLoading = true;
  List<chat_models.Message> messages = [];
  Map<String, int> messageTypeCount = {};
  Map<String, int> messagesByDay = {};
  double averageResponseTime = 0;
  int totalMessages = 0;
  int readMessages = 0;
  int unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load messages for this chat
      final chatMessages = await _demoData.getMessages(widget.chat.id);

      // Process data for analytics
      _processMessageData(chatMessages);

      setState(() {
        messages = chatMessages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load data: $e');
    }
  }

  void _processMessageData(List<chat_models.Message> chatMessages) {
    // Reset counters
    messageTypeCount = {'text': 0, 'image': 0, 'audio': 0};
    messagesByDay = {};
    totalMessages = chatMessages.length;
    readMessages = 0;
    unreadMessages = 0;

    // Count message types and read/unread status
    for (var message in chatMessages) {
      // Count by message type
      if (messageTypeCount.containsKey(message.type)) {
        messageTypeCount[message.type] =
            (messageTypeCount[message.type] ?? 0) + 1;
      } else {
        messageTypeCount[message.type] = 1;
      }

      // Count read/unread
      if (message.isRead) {
        readMessages++;
      } else {
        unreadMessages++;
      }

      // Group by day (simplified implementation)
      // In a real app, you would parse the timestamp properly
      final day = message.timestamp.split(' ')[0];
      messagesByDay[day] = (messagesByDay[day] ?? 0) + 1;
    }

    // Calculate average response time (simplified)
    // In a real app, you'd calculate actual time differences between messages
    averageResponseTime =
        chatMessages.isNotEmpty ? 10.5 : 0; // Placeholder value
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.chat.title} Analytics')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    _buildMessageTypesChart(),
                    const SizedBox(height: 20),
                    _buildMessagesOverTimeChart(),
                    const SizedBox(height: 20),
                    _buildReadUnreadChart(),
                  ],
                ),
              ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  Icons.message,
                  totalMessages.toString(),
                  'Total Messages',
                  Colors.blue,
                ),
                _buildSummaryItem(
                  Icons.timer,
                  '${averageResponseTime.toStringAsFixed(1)} min',
                  'Avg Response',
                  Colors.orange,
                ),
                _buildSummaryItem(
                  Icons.mark_chat_read,
                  '$readMessages/$totalMessages',
                  'Read Rate',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMessageTypesChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Message Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: messageTypeCount['text']?.toDouble() ?? 0,
                      title: 'Text',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: messageTypeCount['image']?.toDouble() ?? 0,
                      title: 'Image',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: messageTypeCount['audio']?.toDouble() ?? 0,
                      title: 'Audio',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesOverTimeChart() {
    // Create data for the bar chart
    final List<BarChartGroupData> barGroups = [];
    messagesByDay.forEach((day, count) {
      barGroups.add(
        BarChartGroupData(
          x: barGroups.length,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Message Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  barGroups.isEmpty
                      ? const Center(child: Text('No data available'))
                      : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              barGroups
                                  .map((group) => group.barRods.first.toY)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 ||
                                      value >= messagesByDay.keys.length) {
                                    return const Text('');
                                  }
                                  return Text(
                                    messagesByDay.keys.elementAt(value.toInt()),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5 != 0) {
                                    return const Text('');
                                  }
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                          gridData: FlGridData(show: true),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadUnreadChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Message Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: readMessages.toDouble(),
                      title: 'Read',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: unreadMessages.toDouble(),
                      title: 'Unread',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
