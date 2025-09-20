class WeightEntry {
  const WeightEntry({required this.date, required this.weightKg});

  final DateTime date;
  final double weightKg;

  factory WeightEntry.fromStorage(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      'date': date.toIso8601String(),
      'weightKg': weightKg,
    };
  }
}
