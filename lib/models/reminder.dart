import "../l10n/app_localizations.dart";

class Reminder {
  Reminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.dateTime,
    this.notes,
    bool? isRepeating,
    String? repeatInterval,
    int? repeatCount,
  })  : isRepeating = isRepeating ?? false,
        repeatInterval = repeatInterval ?? 'once',
        repeatCount = repeatCount ?? 1;

  final String id;
  final String petId;
  final String title;
  final String type;
  final DateTime dateTime;
  final String? notes;
  final bool isRepeating;
  final String repeatInterval;
  final int repeatCount;

  factory Reminder.fromStorage(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      petId: json['petId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      isRepeating: json['isRepeating'] as bool? ?? false,
      repeatInterval: json['repeatInterval'] as String? ?? 'once',
      repeatCount: json['repeatCount'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toStorage() => {
        'id': id,
        'petId': petId,
        'title': title,
        'type': type,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
        'isRepeating': isRepeating,
        'repeatInterval': repeatInterval,
        'repeatCount': repeatCount,
      };

  int get totalOccurrences => isRepeating ? repeatCount : 1;

  DateTime occurrenceAt(int index) {
    if (index <= 0) {
      return dateTime;
    }
    switch (repeatInterval) {
      case '12h':
        return dateTime.add(Duration(hours: 12 * index));
      case 'daily':
        return dateTime.add(Duration(days: index));
      case 'weekly':
        return dateTime.add(Duration(days: 7 * index));
      case 'monthly':
        return _addMonths(dateTime, index);
      case 'quarterly':
        return _addMonths(dateTime, 3 * index);
      case 'yearly':
        return DateTime(dateTime.year + index, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
      default:
        return dateTime;
    }
  }

  DateTime? nextOccurrence(DateTime from) {
    final total = totalOccurrences;
    for (var i = 0; i < total; i++) {
      final occurrence = occurrenceAt(i);
      if (!occurrence.isBefore(from)) {
        return occurrence;
      }
    }
    return null;
  }

  String recurrenceSummary(AppLocalizations l10n) {
    if (!isRepeating || repeatCount <= 1 || repeatInterval == 'once') {
      return '';
    }
    final interval = l10n.reminderIntervalName(repeatInterval);
    final count = l10n.reminderRepeatCount(repeatCount);
    final template = l10n.reminderRepeatSummaryTemplate;
    return template.replaceFirst('{interval}', interval).replaceFirst('{count}', count);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final year = date.year + (date.month + months - 1) ~/ 12;
    final month = (date.month + months - 1) % 12 + 1;
    final day = date.day;
    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final clampedDay = day > lastDayOfTargetMonth ? lastDayOfTargetMonth : day;
    return DateTime(year, month, clampedDay, date.hour, date.minute);
  }
}

