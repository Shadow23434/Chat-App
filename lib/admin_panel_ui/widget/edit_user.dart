import 'package:chat_app/admin_panel_ui/widget/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditUser extends StatefulWidget {
  const EditUser({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.gender,
    required this.profilePic,
  });

  final String username;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final String profilePic;

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _userNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _profilePicFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();
  final List<String> gender = ['male', 'female', 'unknown'];
  String? _selectedGender;
  bool _showErrors = false;

  Future<void> _editUser() async {
    setState(() {
      _showErrors = true;
    });
    if (_userNameFormKey.currentState!.validate() &&
        _emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate() &&
        _phoneNumberFormKey.currentState!.validate() &&
        _profilePicFormKey.currentState!.validate()) {
      // Add database

      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    // Convert the gender string to lowercase to match our dropdown items
    _selectedGender = widget.gender.toLowerCase();

    // Initialize the text controllers with the widget values
    _userNameController.text = widget.username;
    _emailController.text = widget.email;
    _passwordController.text = widget.password;
    _profilePicController.text = widget.profilePic;
    _phoneNumberController.text = widget.phone;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _profilePicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardView,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Edit user'),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconNoBorder(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Input(
                  lable: 'Username',
                  value: widget.username,
                  icon: Icons.person_rounded,
                  controller: _userNameController,
                  formkey: _userNameFormKey,
                  showErrors: _showErrors,
                ),
                SizedBox(height: 12),
                Input(
                  lable: 'Email',
                  value: widget.email,
                  icon: Icons.email_rounded,
                  controller: _emailController,
                  formkey: _emailFormKey,
                  showErrors: _showErrors,
                  isEmail: true,
                ),
                SizedBox(height: 12),
                Input(
                  lable: 'Password',
                  value: widget.password,
                  icon: Icons.lock,
                  controller: _passwordController,
                  formkey: _passwordFormKey,
                  showErrors: _showErrors,
                  isPassword: true,
                ),
                SizedBox(height: 12),
                // Gender
                Row(
                  children: [
                    Text('Gender: '),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedGender,
                      dropdownColor: AppColors.cardView,
                      borderRadius: BorderRadius.circular(12),
                      underline: SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      items:
                          gender.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item.substring(0, 1).toUpperCase() +
                                    item.substring(1),
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // ProfilePic
                Input(
                  lable: 'Image Url',
                  value: widget.profilePic,
                  icon: Icons.image_outlined,
                  controller: _profilePicController,
                  formkey: _profilePicFormKey,
                  showErrors: _showErrors,
                ),
                SizedBox(height: 12),
                // Phone
                Input(
                  lable: 'Phone Number',
                  value: widget.phone,
                  icon: Icons.phone_android,
                  isPhone: true,
                  controller: _phoneNumberController,
                  formkey: _phoneNumberFormKey,
                  showErrors: _showErrors,
                ),
                // Button
                SizedBox(height: 20),
                ButtonBackground(
                  onTap: () => _editUser(),
                  string: 'Save',
                  textSize: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
