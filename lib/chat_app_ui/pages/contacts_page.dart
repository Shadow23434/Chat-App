import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/widgets/avatar.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<User> demoUsers = users;

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
  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Avatar.medium(
          url: user.profileUrl,
          onTap: () => Navigator.of(context).push(ProfileScreen.route(user)),
        ),
        title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
        onTap: () {},
      ),
    );
  }
}
