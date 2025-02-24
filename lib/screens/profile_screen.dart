import 'package:chat_app/screens/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const ProfileScreen());

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.currentUser;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackGround(
            icon: CupertinoIcons.back,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Hero(
              tag: 'hero-profile-picture',
              child: Avatar.large(url: user?.image ?? defaultAvatarUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(user?.name ?? "Unknown"),
            ),
            const Divider(),
            const _SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatefulWidget {
  const _SignOutButton();

  @override
  __SignOutButtonState createState() => __SignOutButtonState();
}

class __SignOutButtonState extends State<_SignOutButton> {
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
    });
    try {
      final nav = Navigator.of(context);
      await StreamChatCore.of(context).client.disconnectUser();
      //firebase
      nav.pushReplacement(SelectUserScreen.route);
    } on Exception catch (e) {
      logger.e(e);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const CircularProgressIndicator(color: AppColors.secondary)
        : TextButton(
          onPressed: _signOut,
          child: const Text(
            'Sign out',
            style: TextStyle(color: AppColors.secondary),
          ),
        );
  }
}
