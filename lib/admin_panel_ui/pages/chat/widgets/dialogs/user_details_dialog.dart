import 'package:flutter/material.dart';
import 'package:chat_app/core/models/index.dart';

class UserDetailsDialog extends StatelessWidget {
  const UserDetailsDialog({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.profilePic),
            ),
          ),
          const SizedBox(height: 16),
          Text('Name: ${user.username}'),
          Text('Email: ${user.email}'),
          if (user.lastLogin != null) Text('Last Login: ${user.lastLogin}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
