import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class HelpCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> descriptions;

  HelpCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.descriptions,
  });
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'How do I manage user accounts?',
      answer:
          'You can manage user accounts from the Users page. There you can view, filter, and search for specific users. Click on a user to view their details, edit information, or deactivate their account.',
    ),
    FaqItem(
      question: 'How can I view chat messages between users?',
      answer:
          'Navigate to the Chats page, where you can see all conversations. You can filter by date, participants, or use the search function. Click on any chat to view the full message history between users.',
    ),
    FaqItem(
      question: 'How do I moderate stories?',
      answer:
          'The Stories page provides tools to view and moderate user stories. You can filter by status (active or expired), search for specific content, and remove inappropriate stories when necessary.',
    ),
    FaqItem(
      question: 'Can I view call logs between users?',
      answer:
          'Yes, the Calls page shows a detailed log of all voice and video calls between users. You can see call duration, time, participants, and call status (received or missed).',
    ),
    FaqItem(
      question: 'How do I generate usage reports?',
      answer:
          'Go to the Analytics section to generate various reports about app usage, active users, message volumes, and other metrics. You can customize date ranges and export reports in different formats.',
    ),
    FaqItem(
      question: 'What should I do if I find inappropriate content?',
      answer:
          'If you find content that violates our community guidelines, you should immediately remove it using the delete function available on the respective content page. For serious violations, you may want to suspend the user account as well.',
    ),
  ];

  final List<HelpCategory> _helpCategories = [
    HelpCategory(
      title: 'User Management',
      icon: Icons.people,
      color: Colors.blue,
      descriptions: [
        'View and search user profiles',
        'Reset user passwords',
        'Deactivate or ban accounts',
        'Manage user roles and permissions',
      ],
    ),
    HelpCategory(
      title: 'Content Moderation',
      icon: Icons.content_paste,
      color: Colors.orange,
      descriptions: [
        'Review and delete inappropriate content',
        'Monitor reported messages',
        'Filter and search content by keywords',
        'Apply content restrictions',
      ],
    ),
    HelpCategory(
      title: 'Analytics & Reporting',
      icon: Icons.analytics,
      color: Colors.green,
      descriptions: [
        'Generate usage reports',
        'Track user engagement metrics',
        'Monitor system performance',
        'Export data for external analysis',
      ],
    ),
    HelpCategory(
      title: 'System Configuration',
      icon: Icons.settings,
      color: Colors.purple,
      descriptions: [
        'Manage app settings',
        'Configure notification rules',
        'Set up automated moderation',
        'Customize user experience parameters',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: const Text(
              'Help',
              style: TextStyle(color: AppColors.textLight, fontSize: 24),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildHelpHeader(),
          SizedBox(height: 24),
          Text(
            'Admin Panel Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _helpCategories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(_helpCategories[index]);
            },
          ),
          SizedBox(height: 32),
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 16),
          _buildFaqSection(),
          SizedBox(height: 32),
          _buildContactSupport(),
        ],
      ),
    );
  }

  Widget _buildHelpHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.secondary, size: 32),
              SizedBox(width: 12),
              Text(
                'Admin Panel Help Center',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Welcome to the Admin Panel Help Center. Here you can find information about managing users, moderating content, and accessing analytics within the chat application.',
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildQuickHelpButton(
                'User Guide',
                Icons.book,
                onTap: () {
                  // Open user guide
                },
              ),
              SizedBox(width: 12),
              _buildQuickHelpButton(
                'Video Tutorials',
                Icons.play_circle_outline,
                onTap: () {
                  // Open video tutorials
                },
              ),
              SizedBox(width: 12),
              _buildQuickHelpButton(
                'Contact Support',
                Icons.support_agent,
                onTap: () {
                  // Open contact form
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpButton(
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.secondary),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(HelpCategory category) {
    return Card(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: category.color.withOpacity(0.2),
                  child: Icon(category.icon, color: category.color),
                ),
                SizedBox(width: 12),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: category.descriptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: category.color,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.descriptions[index],
                            style: TextStyle(
                              color: AppColors.textFaded,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.all(0),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _faqItems[index].isExpanded = !isExpanded;
        });
      },
      children:
          _faqItems.map<ExpansionPanel>((FaqItem item) {
            return ExpansionPanel(
              backgroundColor: AppColors.cardDark,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    item.question,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          isExpanded
                              ? AppColors.secondary
                              : AppColors.textLight,
                    ),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.answer,
                      style: TextStyle(
                        color: AppColors.textFaded,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              isExpanded: item.isExpanded,
            );
          }).toList(),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need More Help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'If you couldn\'t find the information you were looking for, our support team is here to help.',
            style: TextStyle(color: AppColors.textFaded),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open email support
                  },
                  icon: Icon(Icons.email),
                  label: Text('Email Support'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Open live chat
                  },
                  icon: Icon(Icons.chat_bubble_outline),
                  label: Text('Live Chat'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: AppColors.secondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
