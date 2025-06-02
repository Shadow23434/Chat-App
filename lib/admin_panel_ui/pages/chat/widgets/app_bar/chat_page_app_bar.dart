import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';
import 'search_bar.dart';
import 'user_menu.dart';

enum AccountOption { signOut, info }

class ChatPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatPageAppBar({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.isFocused,
    required this.isClicked,
    required this.onSearch,
    required this.onIsClickedChanged,
    required this.onOptionSelected,
  });

  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isClicked;
  final VoidCallback onSearch;
  final Function(bool) onIsClickedChanged;
  final Function(AccountOption) onOptionSelected;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      leadingWidth: 100,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: Text(
            'Chats',
            style: TextStyle(color: AppColors.textLight, fontSize: 24),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSearchBar(
                controller: searchController,
                focusNode: focusNode,
                onSearch: onSearch,
              ),
              const SizedBox(width: 12),
              UserMenu(
                isClicked: isClicked,
                onIsClickedChanged: onIsClickedChanged,
                onOptionSelected: onOptionSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
