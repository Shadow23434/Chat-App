import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:flutter/material.dart';

class IconBackGround extends StatelessWidget {
  const IconBackGround({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 20,
    this.circularBorder = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool circularBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          circularBorder ? AppColors.circularIcon : Theme.of(context).cardColor,
      borderRadius:
          circularBorder
              ? BorderRadius.circular(999.0)
              : BorderRadius.circular(6.0),
      child: InkWell(
        borderRadius:
            circularBorder
                ? BorderRadius.circular(999.0)
                : BorderRadius.circular(6.0),
        splashColor: circularBorder ? null : AppColors.secondary,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: size),
        ),
      ),
    );
  }
}

class IconBorder extends StatefulWidget {
  const IconBorder({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Colors.transparent,
    this.size = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  @override
  State<IconBorder> createState() => _IconBorderState();
}

class _IconBorderState extends State<IconBorder> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      splashColor:
          (widget.color != Colors.transparent)
              ? Colors.white
              : AppColors.secondary,
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: () {
        widget.onTap();
        setState(() => _isTapped = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: widget.size + 20,
        width: widget.size + 20,
        decoration: BoxDecoration(
          color: _isTapped ? AppColors.secondary : widget.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2, color: Theme.of(context).cardColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
            child: Transform.scale(
              scale: _isTapped ? 0.6 : 1.0,
              child: Icon(widget.icon, size: widget.size),
            ),
          ),
        ),
      ),
    );
  }
}

class IconNoBorder extends StatelessWidget {
  const IconNoBorder({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

class ButtonBackground extends StatelessWidget {
  const ButtonBackground({
    super.key,
    required this.onTap,
    required this.string,
    this.textSize,
    this.color = AppColors.secondary,
  });

  final VoidCallback onTap;
  final String string;
  final double? textSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: color,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.cardLight,
          child: Center(
            child: Text(
              string,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: textSize,
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
  const IconImage({
    super.key,
    required this.src,
    required this.onTap,
    this.scale,
  });

  final String src;
  final VoidCallback onTap;
  final double? scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset(src, scale: scale),
        ),
      ),
    );
  }
}
