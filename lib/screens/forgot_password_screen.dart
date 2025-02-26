import 'package:chat_app/widgets/widgets.dart';
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

  Future<void> _resetPassword() async {
    setState(() {
      _showErrors = true;
    });

    if (_emailFormKey.currentState!.validate()) {
      // reset password
    }
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
                  subtitle: 'Please enter your email to reset the password',
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
                  child: ButtonBackground(
                    onTap: () => _resetPassword(),
                    string: 'Reset Password',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
