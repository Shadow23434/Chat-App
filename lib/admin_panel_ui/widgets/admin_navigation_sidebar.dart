import 'package:chat_app/core/navigation/web_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A simplified navigation sidebar for admin pages
class AdminNavigationSidebar extends StatelessWidget {
  const AdminNavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // App logo
          Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image.asset('assets/images/app_logo.png'),
            ),
          ),
          const SizedBox(height: 30),
          // Navigation items
          _NavItem(
            icon: Icons.account_circle_outlined,
            label: 'Users',
            route: '/admin/user',
          ),
          _NavItem(
            icon: CupertinoIcons.bubble_left_bubble_right,
            label: 'Chat',
            route: '/admin/chat',
          ),
          _NavItem(
            icon: Icons.play_circle_outline,
            label: 'Stories',
            route: '/admin/stories',
          ),
          _NavItem(icon: Icons.phone, label: 'Calls', route: '/admin/calls'),
          _NavItem(
            icon: Icons.help_outline,
            label: 'Help',
            route: '/admin/help',
          ),
          const Spacer(),
          // Logout option
          _NavItem(icon: Icons.logout, label: 'Logout', route: '/login'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Navigation item for the sidebar
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = ModalRoute.of(context)?.settings.name == route;

    return Tooltip(
      message: label,
      preferBelow: false,
      verticalOffset: 20,
      child: GestureDetector(
        onTap: () {
          if (route == '/login') {
            WebNavigation.navigateToClient();
          } else {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 26,
          ),
        ),
      ),
    );
  }
}
