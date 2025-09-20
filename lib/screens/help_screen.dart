import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const routeName = '/help';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help center')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: const [
          Text(
            'Need a hand?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'Use the resources below to get quick answers or reach out to our team. '
            'We will expand this section with FAQs and tutorials soon.',
          ),
          SizedBox(height: 24),
          _HelpItem(
            icon: Icons.forum_outlined,
            title: 'Knowledge base',
            description:
                'Browse popular questions about caring for your pets and managing reminders.',
          ),
          SizedBox(height: 16),
          _HelpItem(
            icon: Icons.chat_bubble_outline,
            title: 'Support chat',
            description:
                'Write to us directly from the app. We typically respond within one business day.',
          ),
          SizedBox(height: 16),
          _HelpItem(
            icon: Icons.mail_outline,
            title: 'Email support',
            description:
                'Prefer email? Drop a message to hello@petdiary.app and we will get back shortly.',
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
