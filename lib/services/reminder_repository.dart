import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';
import "package:hive/hive.dart";

import "../models/reminder.dart";

class ReminderRepository extends ChangeNotifier {
  static const _boxName = "pet_diary_reminders";
  static const _itemsKey = "items";

  late Box _box;
  List<Reminder> _reminders = const [];
  bool _initialized = false;
  Future<void>? _initFuture;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get isInitialized => _initialized;

  Future<void> init() {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    _box = await Hive.openBox(_boxName);
    _reminders = (_box.get(_itemsKey) as List? ?? [])
        .whereType<Map>()
        .map(
          (raw) => Reminder.fromStorage(Map<String, dynamic>.from(raw as Map)),
        )
        .toList();

    if (_reminders.isEmpty) {
      _reminders = _seedReminders();
      await _save();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await init();
  }

  List<Reminder> remindersForPet(String petId) {
    if (!_initialized) {
      return const [];
    }
    final now = DateTime.now();
    final list = _reminders
        .where((reminder) => reminder.petId == petId)
        .toList();
    list.sort((a, b) {
      final aNext = a.nextOccurrence(now) ?? a.dateTime;
      final bNext = b.nextOccurrence(now) ?? b.dateTime;
      return aNext.compareTo(bNext);
    });
    return list;
  }

  List<ReminderOccurrence> upcomingReminders({int limit = 4}) {
    if (!_initialized) {
      return const [];
    }
    final now = DateTime.now();
    final entries = <ReminderOccurrence>[];
    for (final reminder in _reminders) {
      final next = reminder.nextOccurrence(now);
      if (next != null) {
        entries.add(ReminderOccurrence(reminder: reminder, occurrence: next));
      }
    }
    entries.sort((a, b) => a.occurrence.compareTo(b.occurrence));
    return entries.take(limit).toList();
  }

  Future<void> replaceAll(List<Reminder> reminders) async {
    await _ensureInitialized();
    _reminders = List.of(reminders);
    if (kDebugMode) {
      debugPrint('ReminderRepository.replaceAll -> count: ' + _reminders.length.toString());
    }
    await _save();
    notifyListeners();
  }

  Future<void> upsert(Reminder reminder) async {
    await _ensureInitialized();
    final index = _reminders.indexWhere((item) => item.id == reminder.id);
    if (index >= 0) {
      final updated = [..._reminders];
      updated[index] = reminder;
      _reminders = updated;
    } else {
      _reminders = [..._reminders, reminder];
    }
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _ensureInitialized();
    final updated = _reminders.where((item) => item.id != id).toList();
    if (updated.length != _reminders.length) {
      _reminders = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteForPet(String petId) async {
    await _ensureInitialized();
    final updated = _reminders.where((item) => item.petId != petId).toList();
    if (updated.length != _reminders.length) {
      _reminders = updated;
      await _save();
      notifyListeners();
    }
  }

  List<Reminder> _seedReminders() {
    final now = DateTime.now();
    return [
      Reminder(
        id: "reminder_seed_single",
        petId: "pet_luna",
        title: "Vaccine booster",
        type: "vaccination",
        dateTime: now.add(const Duration(days: 2, hours: 3)),
        notes: "Bring passport",
      ),
      Reminder(
        id: "reminder_seed_repeat",
        petId: "pet_luna",
        title: "Medication course",
        type: "medication",
        dateTime: now.add(const Duration(hours: 6)),
        isRepeating: true,
        repeatInterval: "12h",
        repeatCount: 6,
      ),
    ];
  }

  Future<void> _save() async {
    await _box.put(_itemsKey, _reminders.map((r) => r.toStorage()).toList());
  }

  @override
  void dispose() {
    if (_box.isOpen) {
      _box.close();
    }
    super.dispose();
  }
}

class ReminderOccurrence {
  const ReminderOccurrence({required this.reminder, required this.occurrence});

  final Reminder reminder;
  final DateTime occurrence;
}
