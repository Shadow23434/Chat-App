import 'package:chat_app/admin_panel_ui/screens/admin_home_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class AccountInfo extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => AccountInfo());
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardView,
      appBar: AppBar(),
      body: Center(
        child: InkWell(
          onTap:
              () =>
                  Navigator.of(context).pushReplacement(AdminHomeScreen.route),
          child: Icon(Icons.home),
        ),
      ),
    );
  }
}
