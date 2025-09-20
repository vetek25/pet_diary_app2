import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_settings_repository.dart';
import '../services/user_repository.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userRepository = context.watch<UserRepository>();
    final currentLocale = userRepository.profile.localeCode;
    final l10n = context.l10n;

    final languageOptions = <String, String>{};
    for (final locale in AppLocalizations.supportedLocales) {
      final code = locale.languageCode;
      if (languageOptions.containsKey(code)) {
        continue;
      }
      String label;
      if (code == 'ru') {
        label = 'Русский';
      } else if (code == 'uk') {
        label = 'Українська';
      } else {
        label = 'English';
      }
      languageOptions[code] = label;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<NotificationSettingsRepository>(
        builder: (context, notificationRepo, _) {
          final notificationsEnabled = notificationRepo.enabled;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text('Language', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: languageOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      value: entry.key,
                      groupValue: currentLocale,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<UserRepository>().updateLocale(value);
                        }
                      },
                      title: Text(entry.value),
                      activeColor: colorScheme.primary,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text('Notifications', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.notificationMasterToggle),
                      subtitle: Text(l10n.notificationMasterToggleSubtitle),
                      value: notificationRepo.enabled,
                      onChanged: (value) =>
                          notificationRepo.update(enabled: value),
                    ),
                    SwitchListTile(
                      title: Text(l10n.notificationSilentMode),
                      subtitle: Text(l10n.notificationSilentModeSubtitle),
                      value: notificationRepo.silentMode,
                      onChanged: notificationsEnabled
                          ? (value) =>
                                notificationRepo.update(silentMode: value)
                          : null,
                    ),
                    SwitchListTile(
                      title: Text(l10n.notificationDuplicateEmail),
                      subtitle: Text(l10n.notificationDuplicateEmailSubtitle),
                      value: notificationRepo.duplicateEmail,
                      onChanged: notificationsEnabled
                          ? (value) =>
                                notificationRepo.update(duplicateEmail: value)
                          : null,
                    ),
                    const Divider(height: 0),
                    CheckboxListTile(
                      title: Text(l10n.notificationChannelReminders),
                      subtitle: Text(l10n.notificationChannelRemindersSubtitle),
                      value: notificationRepo.receiveReminders,
                      onChanged: notificationsEnabled
                          ? (value) => notificationRepo.update(
                              receiveReminders:
                                  value ?? notificationRepo.receiveReminders,
                            )
                          : null,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.notificationChannelClinic),
                      subtitle: Text(l10n.notificationChannelClinicSubtitle),
                      value: notificationRepo.receiveClinic,
                      onChanged: notificationsEnabled
                          ? (value) => notificationRepo.update(
                              receiveClinic:
                                  value ?? notificationRepo.receiveClinic,
                            )
                          : null,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.notificationChannelBilling),
                      subtitle: Text(l10n.notificationChannelBillingSubtitle),
                      value: notificationRepo.receiveBilling,
                      onChanged: notificationsEnabled
                          ? (value) => notificationRepo.update(
                              receiveBilling:
                                  value ?? notificationRepo.receiveBilling,
                            )
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        l10n.notificationSettingsHint,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
