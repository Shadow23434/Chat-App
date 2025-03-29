import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({super.key});

  @override
  _AddNewUserState createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _userNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _confirmPasswordFormKey = GlobalKey<FormState>();
  bool _showErrors = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    setState(() {
      _showErrors = true;
    });
    if (_userNameFormKey.currentState!.validate() &&
        _emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate() &&
        _confirmPasswordFormKey.currentState!.validate()) {
      // Add database

      Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardView,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Add a new user'),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconNoBorder(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Input(
                lable: 'Username',
                icon: Icons.person_rounded,
                controller: _userNameController,
                formkey: _userNameFormKey,
                showErrors: _showErrors,
              ),
              SizedBox(height: 12),
              Input(
                lable: 'Email',
                icon: Icons.email_rounded,
                controller: _emailController,
                formkey: _emailFormKey,
                showErrors: _showErrors,
                isEmail: true,
              ),
              SizedBox(height: 12),
              Input(
                lable: 'Password',
                icon: Icons.lock,
                controller: _passwordController,
                formkey: _passwordFormKey,
                showErrors: _showErrors,
                isPassword: true,
              ),
              SizedBox(height: 12),
              Input(
                lable: 'Confirm Password',
                icon: Icons.lock,
                controller: _confirmPasswordController,
                formkey: _confirmPasswordFormKey,
                showErrors: _showErrors,
                isPassword: true,
                validator: _confirmPasswordValidator,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {
                      value = !value!;
                    },
                  ),
                  SizedBox(width: 4),
                  Text('Auto confirm user?', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'A confirmation email will not be sent when creating a user via this form.',
                style: TextStyle(color: AppColors.textFaded, fontSize: 13),
              ),
              SizedBox(height: 16),
              ButtonBackground(
                onTap: () => _addUser(),
                string: 'Add',
                textSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
