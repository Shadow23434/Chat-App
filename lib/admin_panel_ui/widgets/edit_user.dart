import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';

class EditUser extends StatefulWidget {
  const EditUser({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.gender,
    required this.profilePic,
    required this.id,
    required this.role,
  });

  final String username;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final String profilePic;
  final String id;
  final String role;

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
  final List<String> roles = ['user', 'admin', 'super_admin'];
  String? _selectedRole;
  final bool _showErrors = false;
  bool _isLoading = false;

  // Image handling
  Uint8List? _profilePicBytes;
  String? _profilePicFileName;
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = ['png', 'jpg', 'jpeg'];

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        final int fileSize = imageBytes.length;

        if (fileSize > _maxImageSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image size must be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final String fileName = image.name;
        final String extension = fileName.split('.').last.toLowerCase();
        if (!_allowedExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Only PNG, JPG, and JPEG files are allowed'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _profilePicBytes = imageBytes;
          _profilePicFileName = fileName;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editUser() async {
    if (!_userNameFormKey.currentState!.validate() ||
        !_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      await userService.editUser(
        userId: widget.id,
        username: _userNameController.text,
        email: _emailController.text,
        password:
            _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
        phoneNumber: _phoneNumberController.text,
        profilePicBytes: _profilePicBytes,
        profilePicFileName: _profilePicFileName,
        gender: _selectedGender,
        role: _selectedRole,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Success',
            'User updated successfully',
            Icons.check_circle_outline_outlined,
            Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Error',
            'Failed to update user: $e',
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender.toLowerCase();
    _selectedRole = widget.role.toLowerCase();
    _userNameController.text = widget.username;
    _emailController.text = widget.email;
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
                Text('User ID: ${widget.id}'),
                SizedBox(height: 12),
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
                // Role Dropdown
                Row(
                  children: [
                    Text('Role: '),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedRole,
                      dropdownColor: AppColors.cardView,
                      borderRadius: BorderRadius.circular(12),
                      underline: SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      items:
                          roles.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Profile Picture
                InkWell(
                  onTap: () => _pickImage(),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardView,
                    ),
                    child:
                        _profilePicBytes != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.memory(
                                _profilePicBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : widget.profilePic.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                widget.profilePic,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.person, size: 50),
                              ),
                            )
                            : Icon(Icons.add_a_photo, size: 50),
                  ),
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
                  onTap: _isLoading ? () {} : () => _editUser(),
                  string: _isLoading ? 'Saving...' : 'Save',
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
