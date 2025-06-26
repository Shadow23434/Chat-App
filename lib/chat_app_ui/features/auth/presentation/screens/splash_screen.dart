import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const SplashScreen());

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthenticatedState();
  }

  Future<void> _handleAuthenticatedState() async {
    // auth
    await Future.delayed(const Duration(milliseconds: 1000));
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
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
