import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:chat_app/admin_panel_ui/pages/pages.dart';
import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({super.key, required this.appTheme});

  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    print('ADMIN: Building Admin app');
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.dark,
      title: "Admin Panel",
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        print('ADMIN ROUTING: ${settings.name}');
        switch (settings.name) {
          case '/':
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const AdminLogInScreen(),
              settings: settings,
            );
          // Changed from /home to /user as the default admin page
          case '/user':
            // Redirect to the full admin panel dashboard
            return MaterialPageRoute(
              builder: (context) => AdminHomeScreen(),
              settings: settings,
            );
          // Add direct routes to specific admin pages
          case '/admin/user':
          case '/admin/chat':
          case '/admin/stories':
          case '/admin/calls':
          case '/admin/help':
            // Instead of creating individual page layouts, use the AdminHomeScreen
            // which will handle showing the right content based on the URL
            return MaterialPageRoute(
              builder: (context) => AdminHomeScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const AdminLogInScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}
