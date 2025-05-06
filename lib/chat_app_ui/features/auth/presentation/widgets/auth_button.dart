import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback login;

  const AuthButton({super.key, required this.login});

  @override
  Widget build(BuildContext context) {
    return ButtonBackground(onTap: () => login, string: 'Log in');
  }
}
