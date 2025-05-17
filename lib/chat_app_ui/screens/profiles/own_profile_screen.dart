import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            child: Avatar.large(url: defaultAvatarUrl),
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
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Auth Error',
                state.error,
                Icons.info_outline,
                AppColors.accent,
              ),
            );
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
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(currentUser.username),
          SizedBox(height: 4),
          Text(
            currentUser.email,
            style: TextStyle(color: AppColors.textFaded, fontSize: 13),
          ),
        ],
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
                  onTap: () => Navigator.of(context).push(EditProfile.route),
                );
              case 1:
                return _SettingItem(
                  icon: Icons.photo_library_outlined,
                  name: 'Your Stories',
                );
              case 2:
                return _SettingItem(
                  icon: Icons.notifications_outlined,
                  name: 'Notifications',
                );
              case 3:
                return _SettingItem(
                  icon: Icons.translate,
                  name: 'Language',
                  hasMenu: true,
                );
              case 4:
                return _SettingItem(
                  icon: Icons.dark_mode_outlined,
                  name: 'Dark Theme',
                  hasButton: true,
                );
              case 5:
                return _SettingItem(
                  icon: Icons.verified_user_outlined,
                  name: 'Private Policy',
                );
              case 6:
                return _SettingItem(
                  icon: Icons.info_outline,
                  name: 'Help & Support',
                );
              case 7:
                return _SettingItem(
                  icon: Icons.alternate_email_outlined,
                  name: 'Contact us',
                );
            }
            return null;
          },
          separatorBuilder: (context, index) => SizedBox(height: 4),
          itemCount: 8,
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
        InkWell(
          onTap: hasButton || hasMenu ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
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
        hasMenu
            ? _LanguageMenu()
            : hasButton
            ? _DarkModeSwitch()
            : SizedBox(),
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
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
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
      child: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: true,
          onChanged: (bool value) {},
          activeColor: AppColors.secondary,
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          inactiveThumbColor: Theme.of(context).iconTheme.color,
          trackOutlineColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.secondary;
            }
            return Theme.of(context).iconTheme.color;
          }),
          trackOutlineWidth: WidgetStateProperty.all(2.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
