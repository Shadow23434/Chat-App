import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class AuthPrompt extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtile;

  const AuthPrompt({
    super.key,
    required this.title,
    required this.subtile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        SizedBox(width: 4.0),
        GestureDetector(
          onTap: onTap,
          child: Text(subtile, style: TextStyle(color: AppColors.secondary)),
        ),
      ],
    );
  }
}
