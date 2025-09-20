import 'dart:io';
import 'dart:math' as math;

import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:fl_chart/fl_chart.dart";
import "package:open_filex/open_filex.dart";
import 'package:intl/intl.dart';
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../models/pet.dart";
import "../models/reminder.dart";
import "../models/pet_document.dart";
import "../models/weight_entry.dart";
import "../services/pet_repository.dart";
import "../services/reminder_repository.dart";
import "../services/document_repository.dart";
import "../services/weight_repository.dart";
import "add_pet_screen.dart";
import "reminder_form_sheet.dart";
import "documents_screen.dart";

class PetCardScreen extends StatelessWidget {
  const PetCardScreen({super.key});
  Future<void> _openDocument(BuildContext context, PetDocument document) async {
    final l10n = context.l10n;
    if (document.isNote) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(document.title),
            content: SingleChildScrollView(child: Text(document.note ?? '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.actionClose),
              ),
            ],
          );
        },
      );
      return;
    }
    final filePath = document.filePath;
    if (filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.documentsFileNotAccessible)),
      );
      return;
    }
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.documentsWebUnsupported)),
      );
      return;
    }
    await OpenFilex.open(filePath);
  }

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
    final pet = petId != null
        ? petRepository.findPetById(petId!) ?? initialPet
        : initialPet;
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
    final documents = context.select<DocumentRepository, List<PetDocument>>((repo) {
      final list = repo.documents.where((doc) => doc.petId == pet.id).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });

    const documentPreviewLimit = 3;

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
                  const SizedBox(height: 24),
                  _WeightTrendSection(pet: pet),
                  const SizedBox(height: 24),
                  Text(
                    l10n.documentsTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (documents.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        l10n.documentsEmptyForPet,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    Column(
                      children: documents
                          .take(documentPreviewLimit)
                          .map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DocumentPreviewTile(
                                document: doc,
                                onTap: () => _openDocument(context, doc),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          DocumentsScreen.routeName,
                          arguments: pet.id,
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(l10n.documentsViewAll),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        child: Text(petNote, style: theme.textTheme.bodyMedium),
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
                            builder: (context) =>
                                ReminderFormSheet(pets: [pet]),
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
                          final next =
                              reminder.nextOccurrence(DateTime.now()) ??
                              reminder.dateTime;
                          final formattedDate = l10n.formatReminderDate(next);
                          final formattedTime = l10n.formatReminderTime(next);
                          final summary = reminder.recurrenceSummary(l10n);
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
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
                                      context.read<ReminderRepository>().delete(
                                        reminder.id,
                                      );
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
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    12,
                                  ),
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
                              (event) => _TimelineTile(
                                event: event,
                                accentColor: pet.accentColor,
                              ),
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
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
                child: Icon(Icons.pets, size: 34, color: pet.accentColor),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
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
              Icon(icon, size: 16, color: Colors.white70),
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

class _WeightTrendSection extends StatelessWidget {
  const _WeightTrendSection({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final weightRepository = context.watch<WeightRepository>();
    final entries = weightRepository.weightsForPet(pet.id);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    final latest = entries.isNotEmpty ? entries.last : null;

    final spots = entries
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.weightKg))
        .toList();

    double? minY;
    double? maxY;
    if (spots.isNotEmpty) {
      minY = entries.map((e) => e.weightKg).reduce(math.min);
      maxY = entries.map((e) => e.weightKg).reduce(math.max);
      final range = (maxY - minY).abs();
      final padding = range == 0 ? 0.5 : math.max(0.2, range * 0.2);
      minY = math.max(0, minY - padding);
      maxY = maxY + padding;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.monitor_weight_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.petProfileWeightTrend,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (latest != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.petProfileWeightLatest(
                            latest.weightKg.toStringAsFixed(1),
                            dateFormat.format(latest.date),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (entries.isEmpty)
              Text(
                l10n.petProfileWeightEmpty,
                style: theme.textTheme.bodyMedium,
              )
            else
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: spots.length <= 1 ? 1 : (spots.length - 1).toDouble(),
                    minY: minY ?? 0,
                    maxY: maxY ?? 1,
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.round().clamp(
                              0,
                              entries.length - 1,
                            );
                            final entry = entries[index];
                            return LineTooltipItem(
                              '${entry.weightKg.toStringAsFixed(1)} kg\n${dateFormat.format(entry.date)}',
                              theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ) ??
                                  const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.dividerColor.withOpacity(0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: spots.length <= 1
                              ? 1
                              : math
                                    .max(1, (spots.length - 1) / 3)
                                    .floorToDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.round();
                            if (index < 0 || index >= entries.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat.Md(
                                  l10n.localeName,
                                ).format(entries[index].date),
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: theme.colorScheme.primary,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.25),
                              theme.colorScheme.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () => _showAddWeightDialog(context, pet),
                icon: const Icon(Icons.add_chart_outlined),
                label: Text(l10n.petProfileAddWeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddWeightDialog(BuildContext context, Pet pet) async {
  final l10n = context.l10n;
  final weightRepository = context.read<WeightRepository>();
  final petRepository = context.read<PetRepository>();
  await weightRepository.init();
  final entries = weightRepository.weightsForPet(pet.id);
  final latest = entries.isNotEmpty ? entries.last : null;
  final weightController = TextEditingController(
    text: (latest?.weightKg ?? pet.weight).toStringAsFixed(1),
  );
  DateTime selectedDate = latest?.date ?? DateTime.now();
  final formKey = GlobalKey<FormState>();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(l10n.petProfileAddWeight),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.petProfileWeightField,
                    ),
                    validator: (value) {
                      final normalized = value?.replaceAll(',', '.');
                      final parsed = double.tryParse(normalized ?? '');
                      if (parsed == null || parsed <= 0) {
                        return l10n.petProfileWeightValidation;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        l10n.petProfileWeightDate(
                          DateFormat.yMMMd(
                            l10n.localeName,
                          ).format(selectedDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: Text(l10n.actionSave),
              ),
            ],
          );
        },
      );
    },
  );

  if (!context.mounted) {
    weightController.dispose();
    return;
  }

  if (confirmed == true) {
    final normalized = weightController.text.replaceAll(',', '.');
    final weightValue = double.parse(normalized);
    final entry = WeightEntry(
      date: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      weightKg: weightValue,
    );
    await weightRepository.addEntry(pet.id, entry);
    await petRepository.savePet(pet.copyWith(weight: weightValue));
  }

  weightController.dispose();
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
          child: Icon(icon, color: theme.colorScheme.primary),
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

class _DocumentPreviewTile extends StatelessWidget {
  const _DocumentPreviewTile({required this.document, required this.onTap});

  final PetDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final subtitle = _buildSubtitle(l10n);
    final dateLabel =
        l10n.formatFullDate(document.updatedAt ?? document.createdAt);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
            theme.colorScheme.onSurface.withOpacity(0.6);

    Widget leading;
    if (document.isImage && document.filePath != null && !kIsWeb) {
      final file = File(document.filePath!);
      if (file.existsSync()) {
        leading = ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            file,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildIconPlaceholder(
              colorScheme.primary,
              Icons.image_outlined,
            ),
          ),
        );
      } else {
        leading = _buildIconPlaceholder(
          colorScheme.primary,
          Icons.image_outlined,
        );
      }
    } else {
      leading = _buildIconPlaceholder(
        colorScheme.primary,
        document.isNote
            ? Icons.sticky_note_2_outlined
            : Icons.insert_drive_file_outlined,
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                          ) ??
                          TextStyle(color: secondaryTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(AppLocalizations l10n) {
    if (document.isNote) {
      final note = document.note?.trim();
      if (note == null || note.isEmpty) {
        return l10n.documentsNoteContentLabel;
      }
      final snippet = note
          .split("\n")
          .map((line) => line.trim())
          .firstWhere((line) => line.isNotEmpty, orElse: () => "");
      return snippet.isEmpty ? l10n.documentsNoteContentLabel : snippet;
    }
    final originalName = document.originalFileName;
    if (originalName != null && originalName.trim().isNotEmpty) {
      return originalName;
    }
    final ext = document.extension;
    if (ext != null && ext.isNotEmpty) {
      return ext.toUpperCase();
    }
    return document.title;
  }

  Widget _buildIconPlaceholder(Color accentColor, IconData icon) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: accentColor, size: 28),
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
            child: Icon(event.icon, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(event.description, style: theme.textTheme.bodyMedium),
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



