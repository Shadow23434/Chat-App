import 'package:flutter/material.dart';

SnackBar customSnackBar(
  String title,
  String message,
  IconData icon,
  Color color,
) {
  return SnackBar(
    content: Container(
      padding: const EdgeInsets.all(8),
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    // padding: EdgeInsets.only(top: 30, right: 24),
    behavior: SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: Duration(seconds: 3),
  );
}
