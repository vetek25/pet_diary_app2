import 'dart:io';

import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:open_filex/open_filex.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../models/pet.dart";
import "../models/pet_document.dart";
import "../services/document_repository.dart";
import "../services/pet_repository.dart";

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  static const routeName = "/documents";

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String? _selectedPetId;
  bool _isPicking = false;
  bool _petsInitialized = false;

  static const _imageExtensions = {"jpg", "jpeg", "png", "heic"};
  static const _fileExtensions = {
    "pdf",
    "doc",
    "docx",
    "xls",
    "xlsx",
    "txt",
    ..._imageExtensions,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pets = context.read<PetRepository>().pets;
    if (!_petsInitialized) {
      _petsInitialized = true;
      if (pets.isNotEmpty) {
        _selectedPetId = pets.first.id;
      }
      return;
    }
    if (_selectedPetId != null &&
        pets.every((pet) => pet.id != _selectedPetId)) {
      _selectedPetId = pets.isEmpty ? null : pets.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final petRepository = context.watch<PetRepository>();
    final pets = petRepository.pets;

    if (pets.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(title: Text(l10n.documentsTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(l10n.documentsNoPets, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_selectedPetId == null ||
        !pets.any((pet) => pet.id == _selectedPetId)) {
      _selectedPetId = pets.first.id;
    }

    final documents = context.select<DocumentRepository, List<PetDocument>>((
      repo,
    ) {
      final list =
          repo.documents.where((doc) => doc.petId == _selectedPetId).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });

    final totalDocs = documents.length;
    final imageCount = documents.where((doc) => doc.isImage).length;
    final noteCount = documents.where((doc) => doc.isNote).length;
    final fileCount = totalDocs - imageCount - noteCount;
    final lastUpdated = documents.isEmpty
        ? null
        : documents
              .map((doc) => doc.updatedAt ?? doc.createdAt)
              .reduce((a, b) => b.isAfter(a) ? b : a);

    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DocumentsHeader(
                subtitle: l10n.documentsHeroSubtitle,
                totalLabel: l10n.documentsStatDocuments(totalDocs),
                lastUpdatedLabel: lastUpdated == null
                    ? null
                    : l10n.documentsLastUpdatedLabel(lastUpdated),
              ),
              const SizedBox(height: 24),
              _PetSelector(
                pets: pets,
                value: _selectedPetId!,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPetId = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              _DocumentsStatsRow(
                stats: [
                  _DocumentsStatData(
                    icon: Icons.folder_copy_outlined,
                    label: l10n.documentsStatDocuments(totalDocs),
                  ),
                  _DocumentsStatData(
                    icon: Icons.image_outlined,
                    label: l10n.documentsStatImages(imageCount),
                  ),
                  _DocumentsStatData(
                    icon: Icons.description_outlined,
                    label: l10n.documentsStatFiles(fileCount),
                  ),
                  _DocumentsStatData(
                    icon: Icons.note_alt_outlined,
                    label: l10n.documentsStatNotes(noteCount),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DocumentsQuickActions(
                onUpload: _isPicking ? null : () => _pickFile(),
                onCreateNote: _isPicking ? null : () => _showNoteDialog(),
              ),
              const SizedBox(height: 20),
              _SupportedFormatsCard(l10n: l10n),
              const SizedBox(height: 16),
              _SectionTitle(title: l10n.documentsLibraryTitle),
            ],
          ),
        ),
      ),
      if (documents.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _EmptyDocumentsState(
              title: l10n.documentsEmptyTitle,
              message: l10n.documentsEmptySubtitle,
              onAdd: _isPicking ? null : () => _showAddDocumentSheet(context),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final document = documents[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == documents.length - 1 ? 0 : 16,
                ),
                child: _DocumentCard(
                  document: document,
                  onOpen: () => _openDocument(document),
                  onRename: () => _showRenameDialog(document),
                  onEditNote: document.isNote
                      ? () => _showNoteDialog(document: document)
                      : null,
                  onDelete: () => _confirmDelete(document),
                ),
              );
            }, childCount: documents.length),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        titleSpacing: 24,
        title: Text(l10n.documentsTitle),
        actions: [
          IconButton(
            onPressed: _isPicking ? null : () => _showAddDocumentSheet(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.documentsAddTooltip,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isPicking ? null : () => _showAddDocumentSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.documentsQuickUpload),
      ),
      body: SafeArea(child: CustomScrollView(slivers: slivers)),
    );
  }

  Future<void> _showAddDocumentSheet(BuildContext context) async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.attach_file_outlined),
                title: Text(l10n.documentsAddFile),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add_outlined),
                title: Text(l10n.documentsAddNote),
                onTap: () {
                  Navigator.pop(context);
                  _showNoteDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    if (_selectedPetId == null) {
      return;
    }
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.documentsWebUnsupported)),
        );
      }
      return;
    }
    setState(() {
      _isPicking = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _fileExtensions.toList(),
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final picked = result.files.single;
      final path = picked.path;
      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.documentsFileNotAccessible)),
          );
        }
        return;
      }
      final file = File(path);
      final isImage = _imageExtensions.contains(
        picked.extension?.toLowerCase(),
      );
      final displayName = picked.name;
      final repository = context.read<DocumentRepository>();
      await repository.createFileDocument(
        petId: _selectedPetId!,
        source: file,
        displayName: displayName,
        isImage: isImage,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.documentsPickError(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  Future<void> _showNoteDialog({PetDocument? document}) async {
    final l10n = context.l10n;
    final titleController = TextEditingController(text: document?.title ?? "");
    final noteController = TextEditingController(text: document?.note ?? "");
    final isEditing = document != null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditing ? l10n.documentsEditNote : l10n.documentsCreateNote,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.documentsNoteTitleLabel,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.documentsNoteContentLabel,
                  ),
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEditing ? l10n.actionSave : l10n.actionCreate),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      titleController.dispose();
      noteController.dispose();
      return;
    }
    final title = titleController.text.trim();
    final note = noteController.text.trim();
    titleController.dispose();
    noteController.dispose();
    if (title.isEmpty || note.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.documentsNoteValidationError)),
      );
      return;
    }
    final repository = context.read<DocumentRepository>();
    if (document == null) {
      await repository.createNoteDocument(
        petId: _selectedPetId!,
        title: title,
        note: note,
      );
    } else {
      await repository.updateDocument(
        document.copyWith(title: title, note: note),
      );
    }
  }

  Future<void> _showRenameDialog(PetDocument document) async {
    final controller = TextEditingController(text: document.title);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.documentsRenameTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.documentsRenameLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionSave),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      final newTitle = controller.text.trim();
      if (newTitle.isNotEmpty) {
        final repository = context.read<DocumentRepository>();
        await repository.updateDocument(document.copyWith(title: newTitle));
      }
    }
    controller.dispose();
  }

  Future<void> _confirmDelete(PetDocument document) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.documentsDeleteTitle),
          content: Text(l10n.documentsDeleteQuestion(document.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      final repository = context.read<DocumentRepository>();
      await repository.deleteDocument(document.id);
    }
  }

  Future<void> _openDocument(PetDocument document) async {
    if (document.isImage && document.filePath != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImagePreviewScreen(document: document),
        ),
      );
      return;
    }
    if (document.isNote) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final l10n = dialogContext.l10n;
          return AlertDialog(
            title: Text(document.title),
            content: SingleChildScrollView(child: Text(document.note ?? "")),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.actionClose),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                  _showNoteDialog(document: document);
                },
                child: Text(l10n.actionEdit),
              ),
            ],
          );
        },
      );
      return;
    }
    if (document.filePath != null) {
      await OpenFilex.open(document.filePath!);
    }
  }
}

class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader({
    required this.subtitle,
    required this.totalLabel,
    this.lastUpdatedLabel,
  });

  final String subtitle;
  final String totalLabel;
  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (lastUpdatedLabel != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lastUpdatedLabel!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsStatData {
  const _DocumentsStatData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _DocumentsStatsRow extends StatelessWidget {
  const _DocumentsStatsRow({required this.stats});

  final List<_DocumentsStatData> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats
          .map(
            (stat) => _DocumentsStatChip(
              icon: stat.icon,
              label: stat.label,
              colorScheme: colorScheme,
              textStyle: theme.textTheme.bodyMedium,
            ),
          )
          .toList(),
    );
  }
}

class _DocumentsStatChip extends StatelessWidget {
  const _DocumentsStatChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DocumentsQuickActions extends StatelessWidget {
  const _DocumentsQuickActions({
    required this.onUpload,
    required this.onCreateNote,
  });

  final VoidCallback? onUpload;
  final VoidCallback? onCreateNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.upload_file_outlined),
          label: Text(l10n.documentsQuickUpload),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onCreateNote,
          icon: const Icon(Icons.note_add_outlined),
          label: Text(l10n.documentsQuickNote),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportedFormatsCard extends StatelessWidget {
  const _SupportedFormatsCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.documentsSupportedFormatsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _FormatRow(
              icon: Icons.image_outlined,
              title: l10n.documentsSupportedImagesHeader,
              subtitle: l10n.documentsSupportedImagesList,
            ),
            _FormatRow(
              icon: Icons.description_outlined,
              title: l10n.documentsSupportedDocsHeader,
              subtitle: l10n.documentsSupportedDocsList,
            ),
            _FormatRow(
              icon: Icons.edit_note_outlined,
              title: l10n.documentsSupportedNotesHeader,
              subtitle: l10n.documentsSupportedNotesList,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatRow extends StatelessWidget {
  const _FormatRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyDocumentsState extends StatelessWidget {
  const _EmptyDocumentsState({
    required this.title,
    required this.message,
    required this.onAdd,
  });

  final String title;
  final String message;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.folder_open_outlined,
                color: colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onAdd != null)
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_outlined),
                label: Text(l10n.documentsAddFirst),
              ),
          ],
        ),
      ),
    );
  }
}

class _PetSelector extends StatelessWidget {
  const _PetSelector({
    required this.pets,
    required this.value,
    required this.onChanged,
  });

  final List<Pet> pets;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        Text(l10n.documentsPetLabel, style: theme.textTheme.titleMedium),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: pets
                .map(
                  (pet) => DropdownMenuItem<String>(
                    value: pet.id,
                    child: Text(pet.name),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
    this.onEditNote,
  });

  final PetDocument document;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback? onEditNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget leading;
    if (document.isImage &&
        document.filePath != null &&
        File(document.filePath!).existsSync()) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(document.filePath!),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    } else {
      final icon = document.isNote
          ? Icons.sticky_note_2_outlined
          : Icons.insert_drive_file_outlined;
      leading = Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: colorScheme.secondary, size: 30),
      );
    }

    final subtitle = document.isNote
        ? (document.note?.split('\n').take(2).join(' ') ?? '')
        : (document.originalFileName ?? document.extension ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_DocumentAction>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                onSelected: (action) {
                  switch (action) {
                    case _DocumentAction.rename:
                      onRename();
                      break;
                    case _DocumentAction.editNote:
                      onEditNote?.call();
                      break;
                    case _DocumentAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: _DocumentAction.rename,
                      child: Text(context.l10n.documentsActionRename),
                    ),
                    if (onEditNote != null)
                      PopupMenuItem(
                        value: _DocumentAction.editNote,
                        child: Text(context.l10n.documentsActionEditNote),
                      ),
                    PopupMenuItem(
                      value: _DocumentAction.delete,
                      child: Text(context.l10n.documentsActionDelete),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DocumentAction { rename, editNote, delete }

class _ImagePreviewScreen extends StatelessWidget {
  const _ImagePreviewScreen({required this.document});

  final PetDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      backgroundColor: Colors.black,
      body: Center(
        child: document.filePath == null
            ? const SizedBox.shrink()
            : InteractiveViewer(child: Image.file(File(document.filePath!))),
      ),
    );
  }
}
