import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../models/pet.dart";
import "../models/reminder.dart";
import "../services/pet_repository.dart";
import "../services/reminder_repository.dart";
import "add_pet_screen.dart";
import "reminder_form_sheet.dart";

class PetCardScreen extends StatelessWidget {
  const PetCardScreen({super.key});

  static const routeName = "/pet";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    Pet? initialPet;
    String? petId;

    if (args is Pet) {
      initialPet = args;
      petId = args.id;
    } else if (args is String) {
      petId = args;
    }

    final petRepository = context.watch<PetRepository>();
    final reminderRepository = context.watch<ReminderRepository>();
    final pet = petId != null ? petRepository.findPetById(petId!) ?? initialPet : initialPet;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.petProfileTitle)),
        body: Center(child: Text(l10n.petProfileNoPetSelected)),
      );
    }

    final timeline = _buildTimeline(pet, l10n);
    final petNote = pet.note(l10n);
    final reminders = reminderRepository.remindersForPet(pet.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(l10n.petProfileTitle),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AddPetScreen.routeName,
                arguments: AddPetScreenArgs(petId: pet.id),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editPetTitle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(pet: pet),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    l10n.petProfileOverview,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _OverviewCard(pet: pet),
                  if (petNote != null && petNote.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n.petProfileNotes,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          petNote,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.petProfileReminders,
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => ReminderFormSheet(
                              pets: [pet],
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_alarm_outlined),
                        label: Text(l10n.addReminderTitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (reminders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        l10n.dashboardNoReminders,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: reminders.map((reminder) {
                          final next = reminder.nextOccurrence(DateTime.now()) ?? reminder.dateTime;
                          final formattedDate = l10n.formatReminderDate(next);
                          final formattedTime = l10n.formatReminderTime(next);
                          final summary = reminder.recurrenceSummary(l10n);
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: pet.accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _iconForReminderType(reminder.type),
                                    color: pet.accentColor,
                                  ),
                                ),
                                title: Text(
                                  reminder.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$formattedDate · $formattedTime'),
                                    if (summary.isNotEmpty)
                                      Text(
                                        summary,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => ReminderFormSheet(
                                          pets: [pet],
                                          initialReminder: reminder,
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      context.read<ReminderRepository>().delete(reminder.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(l10n.editReminderTitle),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(l10n.deleteReminder),
                                    ),
                                  ],
                                ),
                              ),
                              if (reminder.notes != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      reminder.notes!,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                              if (reminder != reminders.last)
                                Divider(
                                  height: 0,
                                  thickness: 1,
                                  color: Colors.black12.withOpacity(0.1),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.petProfileTimeline,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: timeline
                            .map(
                              (event) => _TimelineTile(event: event, accentColor: pet.accentColor),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TimelineEvent> _buildTimeline(Pet pet, AppLocalizations l10n) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        title: l10n.timelineTitle("wellness"),
        description: l10n.timelineDescription("wellness"),
        dateLabel: l10n.formatFullDate(DateTime(2024, 2, 12)),
        icon: Icons.health_and_safety_outlined,
      ),
      _TimelineEvent(
        title: l10n.timelineTitle("bloodTest"),
        description: l10n.timelineDescription("bloodTest"),
        dateLabel: l10n.formatFullDate(DateTime(2024, 1, 8)),
        icon: Icons.biotech_outlined,
      ),
      if (pet.nextEventKey != null && pet.nextEventDate != null)
        _TimelineEvent(
          title: pet.nextEventLabel(l10n) ?? '',
          description: l10n.timelineDescription("upcoming", name: pet.name),
          dateLabel: l10n.timelineUpcomingDateLabel,
          icon: Icons.calendar_month,
        ),
    ];
    return events;
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 32, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            pet.accentColor.withOpacity(0.95),
            pet.accentColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.pets,
                  size: 34,
                  color: pet.accentColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pet.speciesLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pet.tagKeys
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                l10n.tagLabel(tag),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _HeaderInfoTile(
                  title: l10n.petCardAge,
                  value: pet.ageLabel(l10n),
                  icon: Icons.cake_outlined,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _HeaderInfoTile(
                  title: l10n.petCardWeight,
                  value: pet.weightLabel(l10n),
                  icon: Icons.monitor_weight,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _HeaderInfoTile(
                  title: l10n.petCardChip,
                  value: "#${pet.microchipSuffix}",
                  icon: Icons.memory_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderInfoTile extends StatelessWidget {
  const _HeaderInfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OverviewRow(
              icon: Icons.calendar_month,
              label: l10n.petProfileBirthDate,
              value: pet.formattedBirthDate(l10n),
            ),
            const SizedBox(height: 12),
            _OverviewRow(
              icon: Icons.wc,
              label: l10n.petProfileGender,
              value: pet.genderLabel(l10n),
            ),
            const SizedBox(height: 12),
            _OverviewRow(
              icon: Icons.insert_drive_file_outlined,
              label: l10n.petProfileMicrochip,
              value: pet.microchip,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event, required this.accentColor});

  final _TimelineEvent event;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              event.icon,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  event.dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.icon,
  });

  final String title;
  final String description;
  final String dateLabel;
  final IconData icon;
}

IconData _iconForReminderType(String type) {
  switch (type.toLowerCase()) {
    case "vaccination":
      return Icons.vaccines_outlined;
    case "medication":
      return Icons.medication_outlined;
    case "grooming":
    case "care":
      return Icons.content_cut;
    case "checkup":
      return Icons.health_and_safety_outlined;
    default:
      return Icons.event_note;
  }
}
