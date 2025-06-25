import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_event.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_state.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/edit_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/search_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditProfile extends StatefulWidget {
  static Route route() => routeWithBloc();

  // Helper: always wrap with BlocProvider
  static Route routeWithBloc() {
    return MaterialPageRoute(
      builder:
          (context) => BlocProvider(
            create:
                (_) => ProfileBloc(
                  getProfileUseCase: GetProfileUseCase(
                    repository: ProfileRepositoryImpl(
                      remoteDataSource: ProfileRemoteDataSource(),
                    ),
                  ),
                  editProfileUseCase: EditProfileUseCase(
                    repository: ProfileRepositoryImpl(
                      remoteDataSource: ProfileRemoteDataSource(),
                    ),
                  ),
                  searchProfileUseCase: SearchProfileUseCase(
                    repository: ProfileRepositoryImpl(
                      remoteDataSource: ProfileRemoteDataSource(),
                    ),
                  ),
                ),
            child: EditProfile(),
          ),
    );
  }

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
  final List<String> gender = ['male', 'female', 'unknown'];
  String? _selectedGender;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _nameController.text = authState.user.username;
      _phoneController.text = authState.user.phoneNumber ?? '';
      final userGender = (authState.user.gender ?? '').toLowerCase().trim();
      _selectedGender =
          gender.contains(userGender) && userGender.isNotEmpty
              ? userGender
              : 'unknown';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _showErrors = true;
    });

    if (_nameFormKey.currentState!.validate() &&
        _phoneFormKey.currentState!.validate()) {
      String? imageDataUrl;
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        // Detect MIME type from file extension
        String mimeType = 'image/jpeg';
        final extension = _pickedImage!.path.split('.').last.toLowerCase();
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          case 'jpg':
          case 'jpeg':
          default:
            mimeType = 'image/jpeg';
            break;
        }
        final base64String = base64Encode(bytes);
        imageDataUrl = 'data:$mimeType;base64,$base64String';
      }

      context.read<ProfileBloc>().add(
        EditProfileEvent({
          'username': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'gender': _selectedGender,
          if (imageDataUrl != null) 'profilePic': imageDataUrl,
        }),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Success!',
                'Profile updated successfully.',
                Icons.check_circle_outline_rounded,
                Colors.green,
              ),
            );
            context.read<AuthBloc>().add(UpdateUserEvent(state.profile));
            Navigator.of(context).pop();
          } else if (state is ProfileError) {
            customSnackBar(
              'Error!',
              state.message,
              Icons.info_outline_rounded,
              Colors.red,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          return SingleChildScrollView(
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
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String avatarUrl = defaultAvatarUrl;
                        if (_pickedImage != null) {
                          return Avatar.large(
                            file: _pickedImage,
                            isEdited: true,
                            onTap: _pickImage,
                          );
                        }
                        if (state is AuthSuccess) {
                          avatarUrl = state.user.profilePic ?? defaultAvatarUrl;
                        }
                        return Avatar.large(
                          url: avatarUrl,
                          isEdited: true,
                          onTap: _pickImage,
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
                                  child: Text(
                                    item[0].toUpperCase() + item.substring(1),
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
                        // Phone
                        SizedBox(height: 12),
                        InputForm(
                          label: 'Phone',
                          controller: _phoneController,
                          formKey: _phoneFormKey,
                          showErrors: _showErrors,
                          isPhone: true,
                        ),
                      ],
                    ),
                  ),
                  // Button
                  isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      )
                      : ButtonBackground(
                        onTap: () => _confirm(),
                        string: 'Confirm',
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
