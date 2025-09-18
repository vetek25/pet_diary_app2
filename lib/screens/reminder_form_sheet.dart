import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../models/pet.dart";
import "../models/reminder.dart";
import "../services/reminder_repository.dart";

class ReminderFormSheet extends StatefulWidget {
  const ReminderFormSheet({super.key, required this.pets, this.initialReminder});

  final List<Pet> pets;
  final Reminder? initialReminder;

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _repeatCountController;

  late String _selectedPetId;
  String _type = 'checkup';
  late DateTime _dateTime;
  bool _isRepeating = false;
  String _repeatInterval = 'daily';
  int _repeatCount = 2;

  bool get _isEditing => widget.initialReminder != null;

  static const _intervalOptions = [
    '12h',
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialReminder?.title ?? '');
    _notesController = TextEditingController(text: widget.initialReminder?.notes ?? '');
    _dateTime = widget.initialReminder?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
    _selectedPetId = widget.initialReminder?.petId ?? widget.pets.first.id;
    _type = widget.initialReminder?.type ?? 'checkup';
    _isRepeating = widget.initialReminder?.isRepeating ?? false;
    _repeatInterval = widget.initialReminder?.repeatInterval ?? 'daily';
    _repeatCount = widget.initialReminder?.repeatCount ?? (_isRepeating ? 2 : 1);
    if (!_isRepeating) {
      _repeatCount = 2;
    }
    _repeatCountController = TextEditingController(text: _repeatCount.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _repeatCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Future<void> pickDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (time == null) return;
      setState(() {
        _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      });
    }

    Future<void> save() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      var repeatCount = int.tryParse(_repeatCountController.text.trim()) ?? 1;
      if (_isRepeating && repeatCount < 1) {
        repeatCount = 1;
      }

      final reminder = Reminder(
        id: widget.initialReminder?.id ?? "rem_${DateTime.now().millisecondsSinceEpoch}",
        petId: _selectedPetId,
        title: _titleController.text.trim(),
        type: _type,
        dateTime: _dateTime,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isRepeating: _isRepeating,
        repeatInterval: _isRepeating ? _repeatInterval : 'once',
        repeatCount: _isRepeating ? repeatCount : 1,
      );
      await context.read<ReminderRepository>().upsert(reminder);
      if (mounted) Navigator.pop(context);
    }

    Future<void> delete() async {
      if (widget.initialReminder == null) return;
      await context.read<ReminderRepository>().delete(widget.initialReminder!.id);
      if (mounted) Navigator.pop(context);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: SingleChildScrollView(
              controller: controller,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isEditing ? l10n.editReminderTitle : l10n.addReminderTitle,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.reminderPetLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPetId,
                      onChanged: (value) => setState(() => _selectedPetId = value!),
                      items: widget.pets
                          .map(
                            (pet) => DropdownMenuItem(
                              value: pet.id,
                              child: Text(pet.name),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.reminderTitleLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(hintText: l10n.reminderTitleHint),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? l10n.reminderTitleRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.reminderTypeLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      items: ['checkup', 'vaccination', 'medication', 'grooming', 'care']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(l10n.reminderType(value)),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isRepeating,
                      title: Text(l10n.reminderRepeatToggle),
                      onChanged: (value) {
                        setState(() {
                          _isRepeating = value;
                          if (!_isRepeating) {
                            _repeatCount = 1;
                            _repeatCountController.text = '1';
                          } else {
                            if (_repeatCount <= 1) {
                              _repeatCount = 2;
                              _repeatCountController.text = '2';
                            }
                          }
                        });
                      },
                    ),
                    if (_isRepeating) ...[
                      const SizedBox(height: 12),
                      Text(l10n.reminderRepeatIntervalLabel, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _repeatInterval,
                        onChanged: (value) => setState(() => _repeatInterval = value!),
                        items: _intervalOptions
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(l10n.reminderIntervalName(value)),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.reminderRepeatCountLabel, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _repeatCountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        decoration: InputDecoration(hintText: l10n.reminderRepeatCountHint),
                        validator: (value) {
                          if (!_isRepeating) {
                            return null;
                          }
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed < 1) {
                            return l10n.reminderRepeatCountRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                    Text(l10n.reminderDateLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(l10n.formatReminderDate(_dateTime)),
                      subtitle: Text(l10n.formatReminderTime(_dateTime)),
                      onTap: pickDateTime,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.reminderNotesLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: l10n.reminderNotesHint),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (_isEditing)
                          TextButton(
                            onPressed: delete,
                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                            child: Text(l10n.deleteReminder),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.addPetCancel),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: save,
                          child: Text(_isEditing ? l10n.saveChanges : l10n.saveReminder),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
