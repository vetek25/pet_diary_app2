import "package:flutter/material.dart";

import "../l10n/app_localizations.dart";

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.genderKey,
    required this.birthDate,
    required this.weight,
    required this.microchip,
    required this.accentColor,
    required this.tagKeys,
    this.avatarUrl,
    this.notesKey,
    this.notes,
    this.nextEventKey,
    this.nextEventDate,
  });

  final String id;
  final String name;
  final String species;
  final String breed;
  final String genderKey;
  final DateTime birthDate;
  final double weight;
  final String microchip;
  final Color accentColor;
  final List<String> tagKeys;
  final String? avatarUrl;
  final String? notesKey;
  final String? notes;
  final String? nextEventKey;
  final DateTime? nextEventDate;

  factory Pet.fromStorage(Map<String, dynamic> json) {
    return Pet(
      id: json["id"] as String,
      name: json["name"] as String,
      species: json["species"] as String,
      breed: json["breed"] as String,
      genderKey: json["genderKey"] as String,
      birthDate: DateTime.parse(json["birthDate"] as String),
      weight: (json["weight"] as num).toDouble(),
      microchip: json["microchip"] as String? ?? "",
      accentColor: Color(json["accentColor"] as int),
      tagKeys: (json["tagKeys"] as List? ?? []).cast<String>(),
      avatarUrl: json["avatarUrl"] as String?,
      notesKey: json["notesKey"] as String?,
      notes: json["notes"] as String?,
      nextEventKey: json["nextEventKey"] as String?,
      nextEventDate: json["nextEventDate"] == null
          ? null
          : DateTime.parse(json["nextEventDate"] as String),
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      "id": id,
      "name": name,
      "species": species,
      "breed": breed,
      "genderKey": genderKey,
      "birthDate": birthDate.toIso8601String(),
      "weight": weight,
      "microchip": microchip,
      "accentColor": accentColor.value,
      "tagKeys": tagKeys,
      "avatarUrl": avatarUrl,
      "notesKey": notesKey,
      "notes": notes,
      "nextEventKey": nextEventKey,
      "nextEventDate": nextEventDate?.toIso8601String(),
    };
  }

  String weightLabel(AppLocalizations l10n) => "${weight.toStringAsFixed(1)} ${l10n.unitKilograms}";

  String ageLabel(AppLocalizations l10n) {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    var months = now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months -= 1;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    final parts = <String>[];
    if (years > 0) {
      parts.add(l10n.ageYearsLabel(years));
    }
    if (months > 0) {
      parts.add(l10n.ageMonthsLabel(months));
    }
    if (parts.isEmpty) {
      parts.add(l10n.ageUnderOneMonth);
    }
    return parts.join(" / ");
  }

  String genderLabel(AppLocalizations l10n) => l10n.genderLabel(genderKey);

  String get speciesLabel => "$species - $breed";

  String formattedBirthDate(AppLocalizations l10n) => l10n.formatFullDate(birthDate);

  String? note(AppLocalizations l10n) {
    if (notes != null && notes!.isNotEmpty) {
      return notes;
    }
    return notesKey == null ? null : l10n.note(notesKey!);
  }

  String? nextEventLabel(AppLocalizations l10n) {
    if (nextEventKey == null || nextEventDate == null) {
      return null;
    }
    return l10n.nextEventLabel(nextEventKey!, nextEventDate!);
  }

  String get microchipSuffix {
    final sanitized = microchip.replaceAll(RegExp(r"[^A-Za-z0-9]"), "");
    if (sanitized.isEmpty) {
      return microchip;
    }
    if (sanitized.length <= 4) {
      return sanitized.toUpperCase();
    }
    return sanitized.substring(sanitized.length - 4).toUpperCase();
  }
}
