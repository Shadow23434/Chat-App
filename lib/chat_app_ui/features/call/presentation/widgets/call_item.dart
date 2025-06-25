import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallItem extends StatelessWidget {
  final CallEntity call;
  const CallItem({super.key, required this.call});

  String getFormattedTime(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (now.difference(date).inDays == 1) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else if (now.year == date.year) {
      return DateFormat('EEEE, hh:mm a').format(date);
    } else {
      return DateFormat('MM/dd/yy, hh:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMissed = call.status == 'missed';
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(ProfileScreen.routeWithBloc(call.participantId));
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(call.participantProfilePic),
            radius: 22,
          ),
        ),
        title: Text(
          call.participantName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(
              isMissed ? Icons.call_missed : Icons.call_received,
              color: isMissed ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              getFormattedTime(call.endedAt),
              style: TextStyle(
                color: isMissed ? Colors.red : Colors.green,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, color: Colors.grey[300], size: 22),
            const SizedBox(width: 12),
            Icon(Icons.videocam, color: Colors.grey[300], size: 22),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
