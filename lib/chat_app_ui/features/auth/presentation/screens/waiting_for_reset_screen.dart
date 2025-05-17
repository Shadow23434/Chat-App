import 'package:flutter/material.dart';

class WaitingForResetScreen extends StatelessWidget {
  const WaitingForResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check your email')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'A password reset link has been sent to your email.\nPlease check your inbox and follow the instructions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
