import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:flutter/material.dart';

class GlowingActionButton extends StatelessWidget {
  const GlowingActionButton({
    super.key,
    required this.color,
    required this.icon,
    this.size = 48,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 24,
            offset: const Offset(-22, 0),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 24,
            offset: const Offset(22, 0),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 42,
            offset: const Offset(-22, 0),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 42,
            offset: const Offset(22, 0),
          ),
        ],
      ),
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            splashColor: AppColors.cardLight,
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: 26, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
