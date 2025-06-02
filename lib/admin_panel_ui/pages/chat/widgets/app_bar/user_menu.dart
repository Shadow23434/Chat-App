import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'chat_page_app_bar.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({
    super.key,
    required this.isClicked,
    required this.onIsClickedChanged,
    this.onOptionSelected,
  });

  final bool isClicked;
  final Function(bool) onIsClickedChanged;
  final Function(AccountOption)? onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AccountOption>(
      borderRadius: BorderRadius.circular(12),
      offset: const Offset(0, 58),
      tooltip: '',
      onOpened: () => onIsClickedChanged(!isClicked),
      onCanceled: () => onIsClickedChanged(!isClicked),
      onSelected: onOptionSelected,
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<AccountOption>>[
            const PopupMenuItem<AccountOption>(
              value: AccountOption.info,
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('Your Account'),
                ],
              ),
            ),
            const PopupMenuItem<AccountOption>(
              value: AccountOption.signOut,
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Sign out'),
                ],
              ),
            ),
          ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cardView,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Avatar.small(
                url:
                    Provider.of<AuthService>(
                      context,
                    ).currentAdmin?.profilePic ??
                    '',
                onTap: () {},
              ),
              const SizedBox(width: 6),
              Text(
                Provider.of<AuthService>(context).currentAdmin?.username ??
                    'Admin',
                style: const TextStyle(fontSize: 14),
              ),
              isClicked
                  ? const Icon(Icons.keyboard_arrow_up_rounded)
                  : const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
