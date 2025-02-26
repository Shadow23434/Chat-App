import 'package:chat_app/screens/log_in_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app.dart';

class SignUpScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const SignUpScreen());

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _confirmPasswordFormKey = GlobalKey<FormState>();
  bool _showErrors = false;
  bool _loading = false;

  Future<void> _signUp() async {
    setState(() {
      _showErrors = true;
    });

    if (_nameFormKey.currentState!.validate() &&
        _emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate() &&
        _confirmPasswordFormKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        print(cred);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Firebase: ${e.message ?? 'Auth error'}')));
      } catch (e) {
        logger.e('Log in error: ', error: e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred')));
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28.0),
                child: Header(
                  heading: 'Sign up with Email',
                  subtitle:
                      'Get chatting with friends and family today by signing up for our chat app!',
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: [
                  InputForm(
                    label: 'Name',
                    controller: _nameController,
                    formKey: _nameFormKey,
                    showErrors: _showErrors,
                  ),
                  SizedBox(height: 12.0),
                  InputForm(
                    label: 'Email',
                    isEmail: true,
                    controller: _emailController,
                    formKey: _emailFormKey,
                    showErrors: _showErrors,
                  ),
                  SizedBox(height: 12.0),
                  InputForm(
                    label: 'Password',
                    isPassword: true,
                    controller: _passwordController,
                    formKey: _passwordFormKey,
                    showErrors: _showErrors,
                  ),
                  SizedBox(height: 12.0),
                  InputForm(
                    label: 'Confirm Password',
                    isPassword: true,
                    controller: _confirmPasswordController,
                    formKey: _confirmPasswordFormKey,
                    showErrors: _showErrors,
                    validator: _confirmPasswordValidator,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Column(
                  children: [
                    ButtonBackground(
                      onTap: () => _signUp(),
                      string: 'Create an account',
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('You have an account?'),
                        SizedBox(width: 4.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushReplacement(LogInScreen.route);
                          },
                          child: Text(
                            'Log in',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
