import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => CreateNewPasswordScreen());
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _confirmPasswordFormKey = GlobalKey<FormState>();
  bool _showErrors = false;

  Future<void> _updatePassword() async {
    setState(() {
      _showErrors = true;
    });

    if (_passwordFormKey.currentState!.validate() &&
        _confirmPasswordFormKey.currentState!.validate()) {
      // Update backend

      await Navigator.of(
        context,
      ).pushAndRemoveUntil(HomeScreen.route, (Route<dynamic> route) => false);
    }
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
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
        child: Column(
          children: [
            Header(
              heading: 'Set a new password',
              subtitle:
                  'Create a new password. Ensure it differs from previous ones for security',
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 16),
            InputForm(
              label: 'Password',
              controller: _passwordController,
              formKey: _passwordFormKey,
              showErrors: _showErrors,
              isPassword: true,
            ),
            SizedBox(height: 12),
            InputForm(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              formKey: _confirmPasswordFormKey,
              showErrors: _showErrors,
              isPassword: true,
              validator: _confirmPasswordValidator,
            ),
            SizedBox(height: 36),
            ButtonBackground(
              onTap: () => _updatePassword(),
              string: 'Update Password',
            ),
          ],
        ),
      ),
    );
  }
}
