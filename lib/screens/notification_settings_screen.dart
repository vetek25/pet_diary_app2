import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../services/notification_settings_repository.dart";

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettingsTitle),
      ),
      body: Consumer<NotificationSettingsRepository>(
        builder: (context, repo, _) {
          if (!repo.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              SwitchListTile(
                title: Text(l10n.notificationMasterToggle),
                subtitle: Text(l10n.notificationMasterToggleSubtitle),
                value: repo.enabled,
                onChanged: (value) => repo.update(enabled: value),
              ),
              SwitchListTile(
                title: Text(l10n.notificationSilentMode),
                subtitle: Text(l10n.notificationSilentModeSubtitle),
                value: repo.silentMode,
                onChanged: repo.enabled ? (value) => repo.update(silentMode: value) : null,
              ),
              SwitchListTile(
                title: Text(l10n.notificationDuplicateEmail),
                subtitle: Text(l10n.notificationDuplicateEmailSubtitle),
                value: repo.duplicateEmail,
                onChanged: repo.enabled ? (value) => repo.update(duplicateEmail: value) : null,
              ),
              const Divider(height: 32),
              Text(
                l10n.notificationChannelsTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: Text(l10n.notificationChannelReminders),
                subtitle: Text(l10n.notificationChannelRemindersSubtitle),
                value: repo.receiveReminders,
                onChanged: repo.enabled
                    ? (value) => repo.update(receiveReminders: value ?? repo.receiveReminders)
                    : null,
              ),
              CheckboxListTile(
                title: Text(l10n.notificationChannelClinic),
                subtitle: Text(l10n.notificationChannelClinicSubtitle),
                value: repo.receiveClinic,
                onChanged: repo.enabled
                    ? (value) => repo.update(receiveClinic: value ?? repo.receiveClinic)
                    : null,
              ),
              CheckboxListTile(
                title: Text(l10n.notificationChannelBilling),
                subtitle: Text(l10n.notificationChannelBillingSubtitle),
                value: repo.receiveBilling,
                onChanged: repo.enabled
                    ? (value) => repo.update(receiveBilling: value ?? repo.receiveBilling)
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.notificationSettingsHint,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
