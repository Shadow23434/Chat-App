import 'dart:async';
import 'package:chat_app/screens/screens.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class SplashScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const SplashScreen());
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final StreamSubscription<firebase.User?> listener;

  @override
  void initState() {
    super.initState();
    _handleAuthenticatedState();
  }

  Future<void> _handleAuthenticatedState() async {
    final auth = firebase.FirebaseAuth.instance;
    if (!mounted) {
      return;
    }
    listener = auth.authStateChanges().listen((user) async {
      if (user != null) {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'getStreamUserToken',
        );
        final results = await Future.wait([
          callable(),
          Future.delayed(const Duration(milliseconds: 700)),
        ]);

        final client = StreamChatCore.of(context).client;
        await client.connectUser(User(id: user.uid), results[0]!.data);

        Navigator.of(context).pushReplacement(HomeScreen.route);
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        Navigator.of(context).pushReplacement(LogInScreen.route);
      }
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/app_logo.png', height: 100, width: 100),
          SizedBox(height: 24),
          Center(
            child: Text(
              'ChatApp',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
