import 'package:chat_app/chat_app_ui/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (_) => HelpSupportScreen());
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Help & Support',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Find answers to common questions or contact our support team for help.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Divider(thickness: 1.2),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.question_answer,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Frequently Asked Questions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _faqItem(
                        theme,
                        'How do I reset my password?',
                        'Go to the login screen and tap on "Forgot password?". Follow the instructions sent to your email.',
                      ),
                      const SizedBox(height: 10),
                      _faqItem(
                        theme,
                        'How do I report a bug?',
                        'Contact our support team using the button below or email us at support@chatapp.com.',
                      ),
                      const SizedBox(height: 10),
                      _faqItem(
                        theme,
                        'How do I delete my account?',
                        'Go to your profile settings and select "Delete Account" at the bottom.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement contact support action
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text(
                    'Contact Support',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  Widget _faqItem(ThemeData theme, String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(answer, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
