import 'package:chat_app/chat_app_ui/features/auth/data/models/user_model.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/chat_app_ui/widgets/avatar.dart';
import 'package:chat_app/core/models/user_model.dart' hide UserModel;
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<UserModel> demoUsers = Helpers.users.cast<UserModel>();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '${demoUsers.length} contacts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: demoUsers.length,
              itemBuilder: (context, index) {
                return ContactCard(user: demoUsers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Avatar.medium(
          url: user.profilePic,
          onTap: () => Navigator.of(context).push(ProfileScreen.route(user)),
        ),
        title: Text(
          user.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        onTap: () {},
      ),
    );
  }
}
