import 'package:chat_app/chat_app_ui/app.dart';
import 'package:chat_app/chat_app_ui/screens/profiles/own_profile_screen.dart';
import 'package:chat_app/chat_app_ui/widgets/edit_avatar_dialog.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => EditProfile());
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  bool _showErrors = false;
  final List<String> gender = ['Male', 'Female', 'Unknown'];
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = 'Male';
  }

  Future<void> _confirm() async {
    setState(() {
      _showErrors = true;
    });

    if (_nameFormKey.currentState!.validate() &&
        _phoneFormKey.currentState!.validate()) {
      // Edit database

      await Navigator.of(context).pushReplacement(OwnProfileScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                heading: 'Edit Profile',
                crossAxisAlignment: CrossAxisAlignment.start,
                textAlign: TextAlign.start,
              ),
              // Avatar
              Center(
                child: Avatar.large(
                  url: defaultAvatarUrl,
                  isEdited: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return EditAvatarDialog();
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputForm(
                      label: 'Name',
                      controller: _nameController,
                      formKey: _nameFormKey,
                      showErrors: _showErrors,
                      value: 'Puerto Rico',
                    ),
                    SizedBox(height: 12),
                    // Gender
                    Text('Gender'),
                    DropdownButton<String>(
                      value: _selectedGender,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Theme.of(context).cardColor,
                      focusColor: Colors.transparent,
                      underline: SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.centerLeft,
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      items:
                          gender.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                    // Phone
                    SizedBox(height: 12),
                    InputForm(
                      label: 'Phone',
                      controller: _phoneController,
                      formKey: _phoneFormKey,
                      showErrors: _showErrors,
                      value: '(320) 235-0504',
                      isPhone: true,
                    ),
                  ],
                ),
              ),
              // Button
              ButtonBackground(onTap: () => _confirm(), string: 'Confirm'),
            ],
          ),
        ),
      ),
    );
  }
}
