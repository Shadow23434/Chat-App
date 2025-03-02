import 'dart:async';
import 'package:chat_app/screens/log_in_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

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

        List<String> logInMethods = await firebase.FirebaseAuth.instance
            .fetchSignInMethodsForEmail(email);

        if (logInMethods.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              'Opps, Error!',
              'No account found with this email.',
              Icons.error_outline_rounded,
              AppColors.accent,
            ),
          );
          return;
        }

        await firebase.FirebaseAuth.instance.sendPasswordResetEmail(
          email: email,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Success!',
            'Password reset email sent. Check your inbox.',
            Icons.check_circle_outline_rounded,
            Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(LogInScreen.route);
      } on firebase.FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Opps, Error!',
            e.message ?? 'An error occurred',
            Icons.error_outline_rounded,
            AppColors.accent,
          ),
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
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: IconNoBorder(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 36),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
      ),
    );
  }
}
