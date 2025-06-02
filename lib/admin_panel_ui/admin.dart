import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/theme.dart';

class Admin extends StatelessWidget {
  final AppTheme appTheme;

  const Admin({super.key, required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => Dio()),
        Provider(create: (_) => const FlutterSecureStorage()),
        ChangeNotifierProxyProvider2<Dio, FlutterSecureStorage, UserService>(
          create:
              (context) => UserService(
                Provider.of<Dio>(context, listen: false),
                Provider.of<FlutterSecureStorage>(context, listen: false),
              ),
          update:
              (context, dio, storage, previous) =>
                  previous ?? UserService(dio, storage),
        ),
        Provider(create: (_) => ChatService()),
      ],
      child: MaterialApp(
        theme: appTheme.light,
        darkTheme: appTheme.dark,
        themeMode: ThemeMode.dark,
        title: "Admin Panel",
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const AdminLogInScreen(),
                settings: settings,
              );
            // Changed from /home to /user as the default admin page
            case '/users':
              return MaterialPageRoute(
                builder: (context) => AdminHomeScreen(),
                settings: settings,
              );
            // Add direct routes to specific admin pages
            case '/admin/users':
            case '/admin/chats':
            case '/admin/stories':
            case '/admin/calls':
            case '/admin/help':
              return MaterialPageRoute(
                builder: (context) => AdminHomeScreen(),
                settings: settings,
              );
            case '/account-info':
              return MaterialPageRoute(
                builder: (context) => AccountInfo(),
                settings: settings,
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const AdminLogInScreen(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
