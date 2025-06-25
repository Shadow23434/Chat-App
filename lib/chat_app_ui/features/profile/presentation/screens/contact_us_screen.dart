import 'package:chat_app/chat_app_ui/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (_) => ContactUsScreen());
  const ContactUsScreen({super.key});

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact.chatapp.team@gmail.com',
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1234567890');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchWebsite() async {
    final Uri webUri = Uri.parse('https://chatapp.com/support');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: AppColors.secondary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Contact Us',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ContactOption(
              icon: Icons.email_outlined,
              label: 'Email: contact.chatapp.team@gmail.com',
              color: AppColors.secondary,
              onTap: _launchEmail,
            ),
            const SizedBox(height: 16),
            _ContactOption(
              icon: Icons.phone_outlined,
              label: 'Phone: +1 234 567 890',
              color: AppColors.secondary,
              onTap: _launchPhone,
            ),
            const SizedBox(height: 16),
            _ContactOption(
              icon: Icons.language,
              label: 'Website: chatapp.com/support',
              color: AppColors.secondary,
              onTap: _launchWebsite,
            ),
            const Spacer(),
            Center(
              child: Text(
                'We are here to help you 24/7!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.open_in_new, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
