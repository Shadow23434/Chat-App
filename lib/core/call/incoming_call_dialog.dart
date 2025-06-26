import 'package:flutter/material.dart';
import 'call_notification.dart';

class IncomingCallDialog extends StatelessWidget {
  final CallNotification call;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallDialog({
    super.key,
    required this.call,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Incoming ${call.isVideo ? 'video' : 'audio'} call'),
      content: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(call.callerAvatar),
            radius: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${call.callerName} is calling you',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onDecline, child: const Text('Decline')),
        ElevatedButton(onPressed: onAccept, child: const Text('Accept')),
      ],
    );
  }
}
