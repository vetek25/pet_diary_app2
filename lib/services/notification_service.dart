import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';
import 'notification_settings_repository.dart';
import 'reminder_repository.dart';

class NotificationService extends ChangeNotifier {
  NotificationService({required this.reminders, required this.settings});

  final ReminderRepository reminders;
  final NotificationSettingsRepository settings;

  bool _initialized = false;
  bool _pluginInitialized = false;
  bool _timeZoneInitialized = false;
  final Map<String, List<DateTime>> _scheduled = {};
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Map<String, List<DateTime>> get scheduledNotifications => {
    for (final entry in _scheduled.entries)
      entry.key: List.unmodifiable(entry.value),
  };

  Future<void> init() async {
    if (_initialized) return;
    await _initializePlugin();
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
      if (_pluginInitialized) {
        unawaited(_notificationsPlugin.cancelAll());
      }
      return;
    }

    final now = DateTime.now();
    final newSchedule = <String, List<DateTime>>{};
    final requests = <_ScheduledNotification>[];
    for (final reminder in reminders.reminders) {
      final occurrences = <DateTime>[];
      final total = reminder.totalOccurrences;
      for (var i = 0; i < total; i++) {
        final occurrence = reminder.occurrenceAt(i);
        if (!occurrence.isBefore(now)) {
          occurrences.add(occurrence);
          requests.add(
            _ScheduledNotification(
              id: _notificationIdFor(reminder.id, i),
              reminder: reminder,
              occurrence: occurrence,
              index: i,
            ),
          );
        }
      }
      if (occurrences.isEmpty) {
        occurrences.add(reminder.dateTime);
      }
      newSchedule[reminder.id] = occurrences;
    }

    _scheduled
      ..clear()
      ..addAll(newSchedule);

    if (_pluginInitialized) {
      unawaited(_applySchedule(requests));
    }

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
    if (_pluginInitialized) {
      unawaited(_notificationsPlugin.cancelAll());
    }
    super.dispose();
  }

  Future<void> _initializePlugin() async {
    if (_initialized || !_isSupportedPlatform || _pluginInitialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open app',
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();
    _pluginInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: !settings.silentMode,
    );

    final macImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: !settings.silentMode,
    );
  }

  Future<void> _ensureTimeZonesLoaded() async {
    if (_timeZoneInitialized) {
      return;
    }
    tz_data.initializeTimeZones();
    if (!kIsWeb) {
      try {
        final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (error) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Failed to set local timezone: $error');
        }
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } else {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timeZoneInitialized = true;
  }

  Future<void> _applySchedule(List<_ScheduledNotification> requests) async {
    if (!_pluginInitialized) {
      return;
    }

    await _notificationsPlugin.cancelAll();

    if (requests.isEmpty) {
      return;
    }

    await _ensureTimeZonesLoaded();
    final details = _buildNotificationDetails();
    final now = DateTime.now();

    for (final request in requests) {
      if (request.occurrence.isBefore(now)) {
        continue;
      }
      try {
        final scheduledDate = tz.TZDateTime.from(request.occurrence, tz.local);
        await _notificationsPlugin.zonedSchedule(
          request.id,
          request.reminder.title,
          _buildBody(request),
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: request.reminder.id,
        );
      } catch (error) {
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            'Failed to schedule notification for ${request.reminder.id}: $error',
          );
        }
      }
    }
  }

  NotificationDetails _buildNotificationDetails() {
    final playSound = !settings.silentMode;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'pet_reminders',
        'Pet reminders',
        channelDescription: 'Scheduled reminders for pet care tasks.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      ),
      linux: const LinuxNotificationDetails(),
    );
  }

  String _buildBody(_ScheduledNotification request) {
    final reminder = request.reminder;
    final notes = reminder.notes?.trim();
    if (notes != null && notes.isNotEmpty) {
      return notes;
    }
    final type = reminder.type.replaceAll('_', ' ').trim();
    final capitalizedType = type.isEmpty
        ? 'Reminder'
        : type[0].toUpperCase() + type.substring(1);
    final formatter = DateFormat.yMMMEd().add_Hm();
    return '$capitalizedType at ${formatter.format(request.occurrence)}';
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      default:
        return false;
    }
  }

  int _notificationIdFor(String reminderId, int occurrenceIndex) {
    final base = _stableHash(reminderId) % 1000000;
    return base * 100 + occurrenceIndex;
  }

  int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }
}

class _ScheduledNotification {
  const _ScheduledNotification({
    required this.id,
    required this.reminder,
    required this.occurrence,
    required this.index,
  });

  final int id;
  final Reminder reminder;
  final DateTime occurrence;
  final int index;
}
