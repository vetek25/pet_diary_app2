import "package:flutter/foundation.dart";

import "../models/reminder.dart";
import "notification_settings_repository.dart";
import "reminder_repository.dart";

class NotificationService extends ChangeNotifier {
  NotificationService({
    required this.reminders,
    required this.settings,
  });

  final ReminderRepository reminders;
  final NotificationSettingsRepository settings;

  bool _initialized = false;
  final Map<String, List<DateTime>> _scheduled = {};

  Map<String, List<DateTime>> get scheduledNotifications => {
        for (final entry in _scheduled.entries) entry.key: List.unmodifiable(entry.value)
      };

  Future<void> init() async {
    if (_initialized) return;
    reminders.addListener(_rescheduleAll);
    settings.addListener(_rescheduleAll);
    if (settings.isInitialized && reminders.isInitialized) {
      _rescheduleAll();
    }
    _initialized = true;
  }

  void _rescheduleAll() {
    if (!reminders.isInitialized || !settings.isInitialized) {
      return;
    }

    if (!settings.enabled || !settings.receiveReminders) {
      _scheduled.clear();
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    _scheduled
      ..clear()
      ..addEntries(reminders.reminders.map((reminder) {
        final occurrences = <DateTime>[];
        final total = reminder.totalOccurrences;
        for (var i = 0; i < total; i++) {
          final occurrence = reminder.occurrenceAt(i);
          if (!occurrence.isBefore(now)) {
            occurrences.add(occurrence);
          }
        }
        if (occurrences.isEmpty) {
          occurrences.add(reminder.dateTime);
        }
        return MapEntry(reminder.id, occurrences);
      }));
    if (kDebugMode) {
      for (final entry in _scheduled.entries) {
        final occurrences = entry.value
            .map((dt) => dt.toIso8601String())
            .take(5)
            .join(', ');
        // ignore: avoid_print
        print('Scheduled notifications for ${entry.key}: $occurrences');
      }
    }
    notifyListeners();
  }

  List<DateTime> upcomingForReminder(String id) => _scheduled[id] ?? const [];

  @override
  void dispose() {
    reminders.removeListener(_rescheduleAll);
    settings.removeListener(_rescheduleAll);
    super.dispose();
  }
}
