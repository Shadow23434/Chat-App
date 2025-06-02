import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminLogInScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => AdminLogInScreen());
  const AdminLogInScreen({super.key});

  @override
  _AdminLogInScreenState createState() => _AdminLogInScreenState();
}

class _AdminLogInScreenState extends State<AdminLogInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _showErrors = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _logIn() async {
    if (!_nameFormKey.currentState!.validate() ||
        !_passwordFormKey.currentState!.validate()) {
      setState(() {
        _showErrors = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Initialize auth information after successful login
        await authService.initializeAuth();
        // Then navigate
        Navigator.of(context).pushReplacementNamed('/users');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );
      }
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
                      lable: 'Email',
                      icon: Icons.email_rounded,
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
                    SizedBox(height: 10),

                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    SizedBox(height: 20),

                    // Log In Button
                    _isLoading
                        ? CircularProgressIndicator()
                        : ButtonBackground(onTap: _logIn, string: 'Login'),
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
