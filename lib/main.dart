import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'app.dart';
import 'screens/select_user_screen.dart';

void main() {
  final client = StreamChatClient(streamKey);
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.client});

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      title: "Chat App",
      builder: (context, child) =>
         StreamChatCore(
            client: client,
            child: child!,
        ),
      home: SelectUserScreen(),
    );
  }
}
