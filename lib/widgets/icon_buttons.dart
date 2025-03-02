import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class IconBackGround extends StatelessWidget {
  const IconBackGround({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(6.0),
        splashColor: AppColors.secondary,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class IconBorder extends StatelessWidget {
  const IconBorder({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      splashColor: AppColors.secondary,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 2, color: Theme.of(context).cardColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class IconNoBorder extends StatelessWidget {
  const IconNoBorder({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(icon)),
    );
  }
}

class ButtonBackground extends StatelessWidget {
  const ButtonBackground({
    super.key,
    required this.onTap,
    required this.string,
  });

  final VoidCallback onTap;
  final String string;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.secondary,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.cardLight,
          child: Center(
            child: Text(
              string,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconImage extends StatelessWidget {
  const IconImage({super.key, required this.src, required this.onTap});

  final String src;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      // clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(src),
        ),
      ),
    );
  }
}
