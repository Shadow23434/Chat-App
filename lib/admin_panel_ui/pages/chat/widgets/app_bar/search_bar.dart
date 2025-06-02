import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.start,
        onFieldSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: 'Search by name, or email',
          hintStyle: const TextStyle(color: AppColors.textFaded),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: IconBorder(
              icon: Icons.search_rounded,
              color: AppColors.secondary,
              size: 20,
              onTap: onSearch,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.cardView,
        ),
      ),
    );
  }
}
