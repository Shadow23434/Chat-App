import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({super.key, required this.appTheme});

  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.dark,
      title: "Admin Panel",
      home: HomeScreen(),
    );
  }
}
