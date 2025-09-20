import 'package:flutter/material.dart';

class AgreementsScreen extends StatelessWidget {
  const AgreementsScreen({super.key});

  static const routeName = '/agreements';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('User agreement')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: const [
          Text(
            'Terms & privacy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'We believe in transparent and secure data handling. This section summarises the key points '
            'from the forthcoming Privacy Policy and Terms of Service. Once the legal text is finalised '
            'it will appear here in full.',
          ),
          SizedBox(height: 24),
          _BulletPoint(
            title: 'Data usage',
            description:
                'Pet information, reminders and documents stay on your device unless you choose to back them up.',
          ),
          SizedBox(height: 16),
          _BulletPoint(
            title: 'Notifications',
            description:
                'You control which reminders are delivered. Disable them at any moment from the settings screen.',
          ),
          SizedBox(height: 16),
          _BulletPoint(
            title: 'Account',
            description:
                'Guest access keeps everything offline. Signing in will enable cloud sync in future releases.',
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(description, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
