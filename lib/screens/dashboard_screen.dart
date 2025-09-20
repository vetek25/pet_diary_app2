import 'dart:io';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../models/pet.dart";
import "../models/reminder.dart";
import "../services/pet_repository.dart";
import "../services/reminder_repository.dart";
import "../services/user_repository.dart";
import "../widgets/pet_card.dart";
import "add_pet_screen.dart";
import "documents_screen.dart";
import "pet_card_screen.dart";
import "profile_screen.dart";
import "reminder_form_sheet.dart";
import "user_settings_screen.dart";

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = "/dashboard";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final petRepository = context.watch<PetRepository>();
    final reminderRepository = context.watch<ReminderRepository>();
    final userRepository = context.watch<UserRepository>();

    final pets = petRepository.pets;
    final reminders = reminderRepository.reminders;
    final profile = userRepository.profile;
    final greetingName = profile.displayName;
    final hasAvatar =
        !kIsWeb &&
        profile.avatarPath != null &&
        File(profile.avatarPath!).existsSync();

    final quickActions = <_QuickActionData>[
      _QuickActionData(
        icon: Icons.upload_file_outlined,
        titleKey: "addDocument",
        subtitleKey: "addDocument",
        color: colorScheme.secondary,
        onTap: () {
          if (pets.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.documentsNoPets)));
            return;
          }
          Navigator.pushNamed(context, DocumentsScreen.routeName);
        },
      ),
      _QuickActionData(
        icon: Icons.vaccines_outlined,
        titleKey: "logClinicVisit",
        subtitleKey: "logClinicVisit",
        color: colorScheme.tertiary,
      ),
      _QuickActionData(
        icon: Icons.alarm_add_outlined,
        titleKey: "createReminder",
        subtitleKey: "createReminder",
        color: colorScheme.primary,
        onTap: () {
          if (pets.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.reminderNoPetsYet)));
            return;
          }
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => ReminderFormSheet(pets: pets),
          );
        },
      ),
      _QuickActionData(
        icon: Icons.pets,
        titleKey: "addPet",
        subtitleKey: "addPet",
        color: colorScheme.secondary,
        onTap: () => _openAddPet(context, petRepository, l10n),
      ),
    ];

    final upcomingEntries = reminderRepository
        .upcomingReminders(limit: 4)
        .map(
          (occurrence) => _ReminderEntry(
            reminder: occurrence.reminder,
            occurrence: occurrence.occurrence,
            pet: petRepository.findPetById(occurrence.reminder.petId),
          ),
        )
        .where((entry) => entry.pet != null)
        .cast<_ReminderEntry>()
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, ProfileScreen.routeName),
                    borderRadius: BorderRadius.circular(36),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.secondary.withOpacity(0.2),
                        backgroundImage: hasAvatar
                            ? FileImage(File(profile.avatarPath!))
                            : null,
                        child: hasAvatar
                            ? null
                            : Icon(
                                Icons.person_outline,
                                color: colorScheme.secondary,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.greeting(greetingName),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.dashboardSummary(pets.length, reminders.length),
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      UserSettingsScreen.routeName,
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(l10n.dashboardBuddies, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                height: 360,
                child: pets.isEmpty
                    ? Center(
                        child: Text(
                          l10n.dashboardNoPetsYet,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 12),
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          return Padding(
                            padding: EdgeInsets.only(left: index == 0 ? 4 : 0),
                            child: PetCard(
                              pet: pet,
                              onTap: () => Navigator.pushNamed(
                                context,
                                PetCardScreen.routeName,
                                arguments: pet.id,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: pets.length,
                      ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.dashboardQuickActions,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: quickActions
                    .map((data) => _QuickActionCard(data: data))
                    .toList(),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.dashboardUpcomingReminders,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (upcomingEntries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    l10n.dashboardNoReminders,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: upcomingEntries.map((entry) {
                        final isLast = entry == upcomingEntries.last;
                        final reminder = entry.reminder;
                        final pet = entry.pet!;
                        final formattedDate = l10n.formatReminderDate(
                          entry.occurrence,
                        );
                        final formattedTime = l10n.formatReminderTime(
                          entry.occurrence,
                        );
                        final summary = reminder.recurrenceSummary(l10n);
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: pet.accentColor.withOpacity(0.12),
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
                                  Text(
                                    "$formattedDate \u00b7 $formattedTime \u00b7 ${pet.name}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (summary.isNotEmpty)
                                    Text(
                                      summary,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => Navigator.pushNamed(
                                context,
                                PetCardScreen.routeName,
                                arguments: pet.id,
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 12,
                                color: colorScheme.outline.withOpacity(0.2),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPet(context, petRepository, l10n),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.dashboardAddPetCta),
      ),
    );
  }

  static void _openAddPet(
    BuildContext context,
    PetRepository repository,
    AppLocalizations l10n,
  ) {
    if (!repository.canAddMorePets) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addPetLimitReached)));
      return;
    }
    Navigator.pushNamed(
      context,
      AddPetScreen.routeName,
      arguments: const AddPetScreenArgs(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: data.color),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.quickActionTitle(data.titleKey),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.quickActionSubtitle(data.subtitleKey),
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color color;
  final VoidCallback? onTap;
}

class _ReminderEntry {
  const _ReminderEntry({
    required this.pet,
    required this.reminder,
    required this.occurrence,
  });

  final Pet? pet;
  final Reminder reminder;
  final DateTime occurrence;
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
