import 'package:flutter/material.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/admin_panel_ui/services/image_service.dart';

class ChatParticipants extends StatelessWidget {
  const ChatParticipants({
    super.key,
    required this.participants,
    required this.onViewUserDetails,
  });

  final List<UserModel> participants;
  final Function(UserModel) onViewUserDetails;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${participants.length}'),
        const SizedBox(width: 4),
        SizedBox(
          width: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.only(right: 4),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return InkWell(
                onTap: () => onViewUserDetails(participant),
                child: Tooltip(
                  message: participant.username,
                  child: ImageService.avatarImage(
                    url: participant.profilePic,
                    radius: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
