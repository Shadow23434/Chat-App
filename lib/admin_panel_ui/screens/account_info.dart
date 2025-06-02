import 'package:chat_app/chat_app_ui/widgets/icon_buttons.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/admin_panel_ui/services/auth/auth_service.dart';
import 'package:intl/intl.dart';

class AccountInfo extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => AccountInfo());
  const AccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardView,
      appBar: AppBar(
        title: const Text(
          'Account Information',
          style: TextStyle(color: AppColors.textLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/users',
                (route) => false,
              ),
        ),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final admin = authService.currentAdmin;
          if (admin == null) {
            return const Center(child: Text('No admin information available'));
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 650,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(admin.profilePic),
                        onBackgroundImageError: (_, __) {},
                        child:
                            admin.profilePic.isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(context, [
                      _buildInfoRow('Username', admin.username),
                      _buildInfoRow('Email', admin.email),
                      _buildInfoRow('Role', admin.role),
                      _buildInfoRow('Gender', admin.gender ?? 'Unknown'),
                      if (admin.phoneNumber != null)
                        _buildInfoRow('Phone', admin.phoneNumber!),
                      if (admin.lastLogin != null)
                        _buildInfoRow(
                          'Last Login',
                          DateFormat(
                            'MMM dd, yyyy HH:mm',
                          ).format(admin.lastLogin!),
                        ),
                    ]),
                    const SizedBox(height: 24),
                    ButtonBackground(
                      onTap:
                          () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          ),
                      string: 'Sign out',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
