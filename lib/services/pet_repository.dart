import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';
import "package:hive/hive.dart";

import "../models/pet.dart";

class PetRepository extends ChangeNotifier {
  PetRepository();

  static const _boxName = "pet_diary";
  static const _petsKey = "pets";

  late Box _box;
  List<Pet> _pets = const [];
  final bool _isFreePlan = true;
  bool _isInitialized = false;
  Future<void>? _initFuture;

  List<Pet> get pets => List.unmodifiable(_pets);
  bool get isFreePlan => _isFreePlan;
  int get petLimit => isFreePlan ? 1 : 5;
  bool get canAddMorePets => _pets.length < petLimit;
  bool get isInitialized => _isInitialized;

  Future<void> init() {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box.get(_petsKey);
    if (stored is List) {
      _pets = stored
          .whereType<Map>()
          .map((raw) => Pet.fromStorage(Map<String, dynamic>.from(raw as Map)))
          .toList();
    }
    if (_pets.isEmpty) {
      _pets = _seedPets();
      await _save();
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }
    await init();
  }

  Pet? findPetById(String id) {
    if (!_isInitialized) {
      return null;
    }
    for (final pet in _pets) {
      if (pet.id == id) {
        return pet;
      }
    }
    return null;
  }

  Future<bool> savePet(Pet pet) async {
    await _ensureInitialized();
    final index = _pets.indexWhere((existing) => existing.id == pet.id);
    if (index >= 0) {
      final updated = [..._pets];
      updated[index] = pet;
      _pets = updated;
    } else {
      if (!canAddMorePets) {
        return false;
      }
      _pets = [..._pets, pet];
    }
    await _save();
    notifyListeners();
    return true;
  }

  Future<bool> addPet(Pet pet) => savePet(pet);

  Future<void> replaceAll(List<Pet> pets) async {
    await _ensureInitialized();
    _pets = List.of(pets);
    if (kDebugMode) {
      debugPrint('PetRepository.replaceAll -> count: ' + _pets.length.toString());
    }
    await _save();
    notifyListeners();
  }

  Future<void> removePet(String id) async {
    await _ensureInitialized();
    final updated = _pets.where((pet) => pet.id != id).toList();
    if (updated.length != _pets.length) {
      _pets = updated;
      await _save();
      notifyListeners();
    }
  }

  List<Pet> _seedPets() {
    return [
      Pet(
        id: "pet_luna",
        name: "Luna",
        species: "Cat",
        breed: "British Shorthair",
        genderKey: "female",
        birthDate: DateTime(2019, 4, 18),
        weight: 4.2,
        microchip: "985 112 000 123 456",
        accentColor: const Color(0xFF8AB6F9),
        tagKeys: const ["indoor", "allergyCare", "microchip"],
        notesKey: "luna",
        nextEventKey: "clinic",
        nextEventDate: DateTime(2024, 3, 21),
      ),
    ];
  }

  Future<void> _save() async {
    await _box.put(_petsKey, _pets.map((pet) => pet.toStorage()).toList());
  }

  @override
  void dispose() {
    if (_box.isOpen) {
      _box.close();
    }
    super.dispose();
  }
}
