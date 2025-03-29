import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/chat_app_ui/theme.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session == null) {
          return const LogInScreen();
        }

        // Current user
        final user = session.user;

        if (user.emailConfirmedAt != null) {
          return HomeScreen();
        } else {
          return LogInScreen();
          // return const OtpVerificationScreen(email: );
        }
      },
    );
  }
}
