import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/weight_entry.dart';

class WeightRepository extends ChangeNotifier {
  static const _boxName = 'pet_diary_weights';
  static const _itemsKey = 'items';

  late Box _box;
  final Map<String, List<WeightEntry>> _entries = {};
  bool _initialized = false;
  Future<void>? _initFuture;

  bool get isInitialized => _initialized;

  Future<void> init() {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    _box = await Hive.openBox(_boxName);
    final raw = _box.get(_itemsKey) as Map?;
    if (raw != null) {
      for (final entry in raw.entries) {
        final petId = entry.key as String;
        final list =
            (entry.value as List? ?? [])
                .whereType<Map>()
                .map(
                  (e) => WeightEntry.fromStorage(Map<String, dynamic>.from(e)),
                )
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));
        _entries[petId] = list;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await init();
  }

  List<WeightEntry> weightsForPet(String petId) {
    if (!_initialized) {
      return const [];
    }
    final entries = _entries[petId];
    return entries == null ? const [] : List.unmodifiable(entries);
  }

  Future<void> replaceAll(Map<String, List<WeightEntry>> entries) async {
    await _ensureInitialized();
    _entries
      ..clear()
      ..addAll(
        entries.map(
          (key, value) => MapEntry(key, List<WeightEntry>.from(value)),
        ),
      );
    if (kDebugMode) {
      debugPrint('WeightRepository.replaceAll -> keys: ' + _entries.length.toString());
    }
    await _save();
    notifyListeners();
  }

  Future<void> addEntry(String petId, WeightEntry entry) async {
    await _ensureInitialized();
    final updated = [..._entries[petId] ?? const <WeightEntry>[]];
    final existingIndex = updated.indexWhere((e) => e.date == entry.date);
    if (existingIndex >= 0) {
      updated[existingIndex] = entry;
    } else {
      updated.add(entry);
    }
    updated.sort((a, b) => a.date.compareTo(b.date));
    _entries[petId] = updated;
    await _save();
    notifyListeners();
  }

  Future<void> deleteEntry(String petId, WeightEntry entry) async {
    await _ensureInitialized();
    final updated = [
      ..._entries[petId] ?? const <WeightEntry>[],
    ]..removeWhere((e) => e.date == entry.date && e.weightKg == entry.weightKg);
    _entries[petId] = updated;
    await _save();
    notifyListeners();
  }

  Map<String, List<Map<String, dynamic>>> exportStorageMap() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final entry in _entries.entries) {
      map[entry.key] = entry.value.map((weight) => weight.toStorage()).toList();
    }
    return map;
  }

  Future<void> _save() async {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final entry in _entries.entries) {
      map[entry.key] = entry.value.map((e) => e.toStorage()).toList();
    }
    await _box.put(_itemsKey, map);
  }

  @override
  void dispose() {
    if (_box.isOpen) {
      _box.close();
    }
    super.dispose();
  }
}
