import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Import for Uint8List

// Remove dart:io as it's not supported on web
// import 'dart:io';

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
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _userNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _confirmPasswordFormKey = GlobalKey<FormState>();
  final bool _showErrors = false;
  bool _isLoading = false;
  String _selectedRole = 'user';
  String _selectedGender = 'male';

  // Use Uint8List to store image data for multi-platform compatibility
  Uint8List? _profilePicBytes;
  String? _profilePicFileName; // To store file name with extension

  // Constants for image validation
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB in bytes
  static const List<String> _allowedExtensions = ['png', 'jpg', 'jpeg'];

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Limit image width
        maxHeight: 1080, // Limit image height
        imageQuality: 85, // Compress image quality
      );

      if (image != null) {
        // Read file as bytes for multi-platform compatibility
        final Uint8List imageBytes = await image.readAsBytes();

        // Check file size using bytes length
        final int fileSize = imageBytes.length;

        if (fileSize > _maxImageSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                'Image size must be less than 5MB',
                Icons.info_outline_rounded,
                AppColors.accent,
              ),
            );
          }
          return;
        }

        // Check file extension from the original file name
        final String fileName = image.name;
        final String extension = fileName.split('.').last.toLowerCase();
        if (!_allowedExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                'Only PNG, JPG, and JPEG files are allowed',
                Icons.info_outline_rounded,
                AppColors.accent,
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
          customSnackBar(
            'Error',
            'Error picking image: ${e.toString()}',
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );
      }
    }
  }

  Future<void> _addUser() async {
    if (!_userNameFormKey.currentState!.validate() ||
        !_emailFormKey.currentState!.validate() ||
        !_passwordFormKey.currentState!.validate() ||
        !_confirmPasswordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      await userService.addUser(
        username: _userNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        profilePicture: _profilePicFileName,
        role: _selectedRole,
        gender: _selectedGender,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Success',
            'User added successfully',
            Icons.check_circle_outline,
            Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Error',
            'Failed to add user: $e',
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
      title: SizedBox(
        width: 600,
        child: Row(
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
              Input(
                lable: 'Phone Number',
                icon: Icons.phone,
                controller: _phoneController,
                formkey: GlobalKey<FormState>(),
                showErrors: _showErrors,
              ),
              SizedBox(height: 12),
              // Role Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardView,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: InputBorder.none,
                  ),
                  items: [
                    DropdownMenuItem(value: 'user', child: Text('user')),
                    DropdownMenuItem(
                      value: 'super_admin',
                      child: Text('super admin'),
                    ),
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRole = value!);
                  },
                ),
              ),
              SizedBox(height: 12),
              // Gender Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardView,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: InputBorder.none,
                  ),
                  items: [
                    DropdownMenuItem(value: 'male', child: Text('male')),
                    DropdownMenuItem(value: 'female', child: Text('female')),
                    DropdownMenuItem(value: 'unknown', child: Text('unknown')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value!);
                  },
                ),
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
                          : Icon(Icons.add_a_photo, size: 50),
                ),
              ),
              SizedBox(height: 16),
              ButtonBackground(
                onTap: _isLoading ? () {} : () => _addUser(),
                string: _isLoading ? 'Adding...' : 'Add',
                textSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
