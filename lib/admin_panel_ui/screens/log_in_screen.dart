import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/admin_panel_ui/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => LoginScreen());
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _showErrors = false;

  Future<void> _logIn() async {
    setState(() {
      _showErrors = true;
    });
    if (_nameFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate()) {
      // Validate database

      Navigator.of(context).pushReplacement(HomeScreen.route);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cardView,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    // User Field
                    Input(
                      lable: 'Username',
                      icon: Icons.person_rounded,
                      controller: _usernameController,
                      formkey: _nameFormKey,
                      showErrors: _showErrors,
                    ),
                    SizedBox(height: 20),
                    // Password Field
                    Input(
                      lable: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      controller: _passwordController,
                      formkey: _passwordFormKey,
                      showErrors: _showErrors,
                    ),
                    SizedBox(height: 30),

                    // Log In Button
                    ButtonBackground(onTap: _logIn, string: 'Login'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
