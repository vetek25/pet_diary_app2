import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_repository.dart';

import '../services/user_repository.dart';
import 'agreements_screen.dart';
import 'help_screen.dart';
import 'profile_edit_screen.dart';
import 'user_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _changeAvatar(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photos are not supported on web yet.'),
        ),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'heic'],
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }
    setState(() => _isUploadingAvatar = true);
    try {
      await context.read<UserRepository>().updateAvatar(File(path));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update photo: $error')));
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userRepository = context.watch<UserRepository>();
    final auth = context.watch<AuthRepository>();
    final isGuest = !auth.isAuthenticated;
    final profile = userRepository.profile;
    final hasAvatar =
        !kIsWeb &&
        profile.avatarPath != null &&
        File(profile.avatarPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.pushNamed(context, UserSettingsScreen.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.15),
                    colorScheme.secondary.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white,
                            backgroundImage: hasAvatar
                                ? FileImage(File(profile.avatarPath!))
                                : null,
                            child: hasAvatar
                                ? null
                                : Icon(
                                    Icons.person_outline,
                                    size: 36,
                                    color: colorScheme.primary,
                                  ),
                          ),
                          if (!isGuest)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: colorScheme.primary,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: _isUploadingAvatar
                                      ? null
                                      : () => _changeAvatar(context),
                                  customBorder: const CircleBorder(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: _isUploadingAvatar
                                        ? SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    colorScheme.onPrimary,
                                                  ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt_outlined,
                                            size: 18,
                                            color: colorScheme.onPrimary,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profile.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            ProfileEditScreen.routeName,
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit profile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            UserSettingsScreen.routeName,
                          ),
                          icon: const Icon(Icons.settings_suggest_outlined),
                          label: const Text('Settings'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Full name',
                      valueSelector: _InfoValueSelector.fullName,
                    ),
                    SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      valueSelector: _InfoValueSelector.address,
                    ),
                    SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      valueSelector: _InfoValueSelector.email,
                    ),
                    SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      valueSelector: _InfoValueSelector.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Help center'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, HelpScreen.routeName),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: Icon(
                      Icons.verified_user_outlined,
                      color: colorScheme.primary,
                    ),
                    title: const Text('User agreement'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AgreementsScreen.routeName,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _InfoValueSelector { fullName, address, email, phone }

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.valueSelector,
  });

  final IconData icon;
  final String label;
  final _InfoValueSelector valueSelector;

  @override
  Widget build(BuildContext context) {
    final profile = context.select<UserRepository, String>((repo) {
      switch (valueSelector) {
        case _InfoValueSelector.fullName:
          return repo.profile.fullName;
        case _InfoValueSelector.address:
          return repo.profile.address;
        case _InfoValueSelector.email:
          return repo.profile.email;
        case _InfoValueSelector.phone:
          return repo.profile.phone;
      }
    });
    final theme = Theme.of(context);

    return Row(
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(profile, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
