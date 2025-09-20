import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../models/pet.dart";
import "../services/pet_repository.dart";
import "../services/reminder_repository.dart";
import "../services/document_repository.dart";
import "../services/document_repository.dart";
import "reminder_form_sheet.dart";

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key, this.petId});

  static const routeName = "/add_pet";

  final String? petId;

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _breedController;
  late final TextEditingController _weightController;
  late final TextEditingController _microchipController;
  late final TextEditingController _notesController;

  DateTime _birthDate = DateTime.now();
  String _gender = "female";
  final Set<String> _selectedTags = {"indoor"};
  Color? _selectedAccent;
  int _accentIndex = 0;
  Pet? _editingPet;

  static const _availableTags = [
    "indoor",
    "allergyCare",
    "microchip",
    "active",
    "noAllergies",
  ];

  static const _accentPreviewColors = [
    Color(0xFF6CC4A1),
    Color(0xFF8AB6F9),
    Color(0xFFF5A8C7),
    Color(0xFFFFC078),
    Color(0xFFBDB2FF),
  ];

  bool get _isEditing => _editingPet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedAccent = _accentPreviewColors.first;

    _speciesController = TextEditingController();
    _breedController = TextEditingController();
    _weightController = TextEditingController();
    _microchipController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditing || widget.petId == null) {
      return;
    }
    final repo = context.read<PetRepository>();
    final pet = repo.findPetById(widget.petId!);
    if (pet == null) {
      return;
    }
    _editingPet = pet;
    _nameController.text = pet.name;
    _speciesController.text = pet.species;
    _breedController.text = pet.breed;
    _weightController.text = pet.weight.toStringAsFixed(1);
    _microchipController.text = pet.microchip;
    _notesController.text = pet.notes ?? "";
    _birthDate = pet.birthDate;
    _gender = pet.genderKey;
    _selectedTags
      ..clear()
      ..addAll(pet.tagKeys.isEmpty ? ["indoor"] : pet.tagKeys);
    _selectedAccent = pet.accentColor;
    _accentIndex = _accentPreviewColors.indexWhere(
      (color) => color.value == pet.accentColor.value,
    );
    if (_accentIndex < 0) {
      _accentIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final repo = context.watch<PetRepository>();

    Future<void> pickBirthDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _birthDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() => _birthDate = picked);
      }
    }

    Future<void> submit() async {
      if (!_isEditing && !repo.canAddMorePets) {
        _showMessage(l10n.addPetLimitReached);
        return;
      }
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
      final weight = double.tryParse(
        _weightController.text.replaceAll(',', '.'),
      );
      if (weight == null) {
        _showMessage(l10n.addPetWeightRequired);
        return;
      }

      final accentColor =
          _selectedAccent ??
          _accentPreviewColors[_accentIndex % _accentPreviewColors.length];
      final pet = Pet(
        id: _editingPet?.id ?? "pet_${DateTime.now().millisecondsSinceEpoch}",
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        genderKey: _gender,
        birthDate: _birthDate,
        weight: weight,
        microchip: _microchipController.text.trim(),
        accentColor: accentColor,
        tagKeys: _selectedTags.toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        avatarUrl: _editingPet?.avatarUrl,
        notesKey: _editingPet?.notesKey,
        nextEventKey: _editingPet?.nextEventKey,
        nextEventDate: _editingPet?.nextEventDate,
      );

      final success = await repo.savePet(pet);
      if (!success) {
        _showMessage(l10n.addPetLimitReached);
        return;
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }

    Future<void> deletePet() async {
      if (_editingPet == null) {
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.deletePetConfirmTitle),
            content: Text(l10n.deletePetConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.addPetCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.deletePetConfirmYes),
              ),
            ],
          );
        },
      );
      if (confirmed == true) {
        await context.read<ReminderRepository>().deleteForPet(_editingPet!.id);
        await context.read<DocumentRepository>().deleteForPet(_editingPet!.id);
        await repo.removePet(_editingPet!.id);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editPetTitle : l10n.addPetTitle),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: deletePet,
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deletePetConfirmTitle,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(theme.textTheme, l10n.addPetNameLabel),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "Luna"),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.addPetNameRequired
                    : null,
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetSpeciesLabel),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(hintText: "Cat"),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.addPetSpeciesRequired
                    : null,
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetBreedLabel),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  hintText: "British Shorthair",
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetGenderLabel),
              DropdownButtonFormField<String>(
                value: _gender,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _gender = value);
                  }
                },
                items: ["female", "male"].map((key) {
                  return DropdownMenuItem(
                    value: key,
                    child: Text(l10n.genderLabel(key)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetBirthDateLabel),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: pickBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.calendar_month),
                    hintText: l10n.addPetBirthDateHelp,
                  ),
                  child: Text(l10n.formatFullDate(_birthDate)),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetWeightLabel),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(hintText: l10n.addPetWeightHint),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.addPetWeightRequired
                    : null,
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetMicrochipLabel),
              TextFormField(
                controller: _microchipController,
                decoration: const InputDecoration(
                  hintText: "985 112 000 123 456",
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetNotesLabel),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Special notes"),
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetTagsLabel),
              Wrap(
                spacing: 8,
                children: _availableTags.map((key) {
                  final selected = _selectedTags.contains(key);
                  return FilterChip(
                    label: Text(l10n.tagLabel(key)),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedTags.add(key);
                        } else {
                          _selectedTags.remove(key);
                          if (_selectedTags.isEmpty) {
                            _selectedTags.add("indoor");
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _sectionLabel(theme.textTheme, l10n.addPetColorLabel),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_accentPreviewColors.length, (index) {
                  final color = _accentPreviewColors[index];
                  final isSelected =
                      (_selectedAccent != null &&
                          _selectedAccent!.value == color.value) ||
                      _accentIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedAccent = color;
                      _accentIndex = index;
                    }),
                    child: Container(
                      width: 52,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: CircleAvatar(backgroundColor: color, radius: 12),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.addPetCancel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submit,
                      child: Text(
                        _isEditing ? l10n.saveChanges : l10n.addPetSave,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(TextTheme textTheme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class AddPetScreenArgs {
  const AddPetScreenArgs({this.petId});

  final String? petId;
}
