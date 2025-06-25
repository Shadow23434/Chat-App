import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/theme/theme_notifier.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/screens/own_stories_screen.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/private_policy_screen.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/help_support_screen.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/screens/contact_us_screen.dart';

class OwnProfileScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const OwnProfileScreen());

  const OwnProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(hasQr: true),
      body: Column(
        children: [
          // Avatar Container
          Hero(
            tag: 'hero-profile-picture',
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess) {
                  return Avatar.large(url: state.user.profilePic);
                } else {
                  return Avatar.large(url: defaultAvatarUrl);
                }
              },
            ),
          ),
          Info(),
          SettingList(),
          // Button
          SignoutButton(),
        ],
      ),
    );
  }
}

class SignoutButton extends StatelessWidget {
  const SignoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocConsumer<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          return ButtonBackground(
            onTap: () => BlocProvider.of<AuthBloc>(context).add(SignoutEvent()),
            string: 'Sign out',
          );
        },
        listener: (context, state) {
          if (state is AuthSuccess) {
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Auth Error',
                state.error,
                Icons.info_outline,
                AppColors.accent,
              ),
            );
          } else if (state is AuthSignedOut) {
            // Navigate to login screen and remove all previous routes
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Column(
              children: [
                Text(state.user.username),
                SizedBox(height: 4),
                Text(
                  state.user.email,
                  style: TextStyle(color: AppColors.textFaded, fontSize: 13),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Text('Loading...'),
                SizedBox(height: 4),
                Text(
                  '',
                  style: TextStyle(color: AppColors.textFaded, fontSize: 13),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class SettingList extends StatelessWidget {
  const SettingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      child: SizedBox(
        height: 370,
        child: ListView.separated(
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _SettingItem(
                  icon: Icons.border_color_outlined,
                  name: 'Edit Profile',
                  onTap: () => Navigator.of(context).push(EditProfile.route()),
                );
              case 1:
                return _SettingItem(
                  icon: Icons.photo_library_outlined,
                  name: 'Your Stories',
                  onTap:
                      () =>
                          Navigator.of(context).push(OwnStoriesScreen.route()),
                );
              case 2:
                return _SettingItem(
                  icon: Icons.translate,
                  name: 'Language',
                  hasMenu: true,
                );
              case 3:
                return _SettingItem(
                  icon: Icons.dark_mode_outlined,
                  name: 'Dark Theme',
                  hasButton: true,
                );
              case 4:
                return _SettingItem(
                  icon: Icons.verified_user_outlined,
                  name: 'Private Policy',
                  onTap:
                      () =>
                          Navigator.of(context).push(PrivatePolicyScreen.route),
                );
              case 5:
                return _SettingItem(
                  icon: Icons.info_outline,
                  name: 'Help & Support',
                  onTap:
                      () => Navigator.of(context).push(HelpSupportScreen.route),
                );
              case 6:
                return _SettingItem(
                  icon: Icons.alternate_email_outlined,
                  name: 'Contact us',
                  onTap:
                      () => Navigator.of(context).push(ContactUsScreen.route),
                );
            }
            return null;
          },
          separatorBuilder: (context, index) => SizedBox(height: 4),
          itemCount: 7,
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.name,
    this.onTap,
    this.hasMenu = false,
    this.hasButton = false,
  });

  final IconData icon;
  final String name;
  final VoidCallback? onTap;
  final bool hasMenu;
  final bool hasButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: hasButton || hasMenu ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.circularIcon,
                      shape: BoxShape.circle,
                    ),
                    child: IconBackGround(icon: icon, circularBorder: true),
                  ),
                  SizedBox(width: 12),
                  Text(name),
                ],
              ),
            ),
          ),
        ),
        hasMenu
            ? _LanguageMenu()
            : hasButton
            ? _DarkModeSwitch()
            : SizedBox.shrink(),
      ],
    );
  }
}

class _LanguageMenu extends StatefulWidget {
  @override
  State<_LanguageMenu> createState() => _LanguageMenuState();
}

class _LanguageMenuState extends State<_LanguageMenu> {
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'vn', 'name': 'VietNamese'},
  ];

  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        padding: EdgeInsets.symmetric(horizontal: 4),
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Theme.of(context).cardColor,
        focusColor: Colors.transparent,
        underline: const SizedBox(),
        alignment: Alignment.center,
        menuMaxHeight: 200,
        items:
            _languages.map((Map<String, String> language) {
              return DropdownMenuItem<String>(
                value: language['code'],
                child: Text(language['name']!),
              );
            }).toList(),
        icon: Icon(Icons.keyboard_arrow_down_rounded),
        style: TextStyle(fontSize: 16),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
            });
            // _changeLanguage(newValue);
          }
        },
      ),
    );
  }
}

class _DarkModeSwitch extends StatelessWidget {
  const _DarkModeSwitch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return PopupMenuButton<ThemeMode>(
            icon: Icon(
              themeNotifier.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : themeNotifier.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
              color: AppColors.secondary,
            ),
            onSelected: (ThemeMode mode) async {
              switch (mode) {
                case ThemeMode.system:
                  await themeNotifier.setSystemTheme();
                  break;
                case ThemeMode.light:
                  await themeNotifier.setLightTheme();
                  break;
                case ThemeMode.dark:
                  await themeNotifier.setDarkTheme();
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
                  PopupMenuItem<ThemeMode>(
                    value: ThemeMode.system,
                    child: Row(
                      children: [
                        Icon(
                          Icons.brightness_auto,
                          color:
                              themeNotifier.themeMode == ThemeMode.system
                                  ? AppColors.secondary
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'System',
                          style: TextStyle(
                            color:
                                themeNotifier.themeMode == ThemeMode.system
                                    ? AppColors.secondary
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<ThemeMode>(
                    value: ThemeMode.light,
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color:
                              themeNotifier.themeMode == ThemeMode.light
                                  ? AppColors.secondary
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Light',
                          style: TextStyle(
                            color:
                                themeNotifier.themeMode == ThemeMode.light
                                    ? AppColors.secondary
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<ThemeMode>(
                    value: ThemeMode.dark,
                    child: Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color:
                              themeNotifier.themeMode == ThemeMode.dark
                                  ? AppColors.secondary
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dark',
                          style: TextStyle(
                            color:
                                themeNotifier.themeMode == ThemeMode.dark
                                    ? AppColors.secondary
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          );
        },
      ),
    );
  }
}
