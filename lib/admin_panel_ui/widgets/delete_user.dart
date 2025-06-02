import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({super.key});

  @override
  _DeleteUserState createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  Future<void> _deleteUser() async {
    // Delete in database
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardView,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Confirm delete user'),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconNoBorder(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete this user?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: ButtonBackground(
                    onTap: () => _deleteUser(),
                    string: 'Delete',
                    color: AppColors.accent,
                    textSize: 16,
                  ),
                ),
                SizedBox(width: 40),
                SizedBox(
                  width: 100,
                  child: ButtonBackground(
                    onTap: () => Navigator.of(context).pop(),
                    string: 'Cancel',
                    color: Colors.blueGrey.withAlpha(50),
                    textSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
