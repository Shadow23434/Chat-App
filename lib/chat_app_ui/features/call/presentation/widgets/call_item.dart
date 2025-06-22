import 'package:chat_app/chat_app_ui/features/call/data/models/call_model.dart';
import 'package:flutter/material.dart';

class CallItem extends StatelessWidget {
  final CallModel call;

  const CallItem({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(call.participantProfilePic),
      ),
      title: Text(call.participantName),
      subtitle: Text(
        'Call ${call.status}',
        style: TextStyle(
          color: call.status == 'missed' ? Colors.red : Colors.green,
        ),
      ),
      trailing: Text(
        _formatDate(call.endedAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
