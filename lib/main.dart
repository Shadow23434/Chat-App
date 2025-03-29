import 'package:flutter/material.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'chat_app_ui/screens/screens.dart';

void main() async {
  runApp(MyApp(appTheme: AppTheme()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appTheme});

  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.system,
      title: "Chat App",
      // home: Admin(appTheme: AppTheme()),
      // home: SplashScreen(),
      home: HomeScreen(),
      // home: ResponsiveLayout(
      //   mobileScafford: const MobileScaffold(),
      //   tabletScafford: const TabletScaffold(),
      //   desktopScafford: const DesktopScaffold(),
      // ),
    );
  }
}
