import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ProcessCard extends StatelessWidget {
  const ProcessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.subtile,
    this.hasBorder = false,
  });

  final IconData icon;
  final String title;
  final String subtile;
  final double value;
  final Color color;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: Colors.white) : null,
          color: AppColors.cardView,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: IconNoBorder(icon: icon, onTap: () {}),
                  ),
                ],
              ),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: color.withAlpha(80),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 5,
                ),
              ),
              Text(
                subtile,
                style: TextStyle(color: AppColors.textFaded, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
