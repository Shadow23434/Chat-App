import 'dart:async';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  bool _showErrors = false;

  Future<void> _send() async {
    setState(() {
      _showErrors = true;
    });

    if (_emailFormKey.currentState!.validate()) {
      try {
        String email = _emailController.text.trim();

        // connect backend

        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Success!',
            'Password reset email sent. Check your inbox.',
            Icons.check_circle_outline_rounded,
            Colors.green,
          ),
        );

        Navigator.of(context).push(
          OtpVerificationScreen(email: email, isForgotPassword: true).route,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Opps, Error!',
            'Something went wrong',
            Icons.error_outline_rounded,
            AppColors.accent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header(
                heading: 'Forgot password',
                subtitle:
                    'Please enter your email to reset the password. We will send a reset link to your email',
                crossAxisAlignment: CrossAxisAlignment.start,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16),
              InputForm(
                label: 'Email',
                isEmail: true,
                controller: _emailController,
                formKey: _emailFormKey,
                showErrors: _showErrors,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: ButtonBackground(onTap: () => _send(), string: 'Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
