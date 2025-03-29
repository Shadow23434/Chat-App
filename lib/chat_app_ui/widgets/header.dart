import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.heading,
    this.subtitle,
    required this.crossAxisAlignment,
    required this.textAlign,
  });

  final String heading;
  final String? subtitle;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          heading,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: textAlign,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            subtitle ?? '',
            style: TextStyle(
              color: AppColors.textFaded,
              fontSize: 14,
              letterSpacing: 0.1,
              fontWeight: FontWeight.w600,
            ),
            textAlign: textAlign,
          ),
        ),
      ],
    );
  }
}
