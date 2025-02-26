import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'app.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final client = StreamChatClient(streamKey);
  runApp(MyApp(client: client, appTheme: AppTheme()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.client, required this.appTheme});

  final StreamChatClient client;
  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.system,
      title: "Chat App",
      builder:
          (context, child) => StreamChatCore(client: client, child: child!),
      home: SplashScreen(),
    );
  }
}
