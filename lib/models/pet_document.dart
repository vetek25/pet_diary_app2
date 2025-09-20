import "dart:io";

import "package:path/path.dart" as p;

enum PetDocumentKind { image, file, note }

class PetDocument {
  const PetDocument({
    required this.id,
    required this.petId,
    required this.title,
    required this.kind,
    required this.createdAt,
    this.updatedAt,
    this.filePath,
    this.originalFileName,
    this.note,
  });

  final String id;
  final String petId;
  final String title;
  final PetDocumentKind kind;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? filePath;
  final String? originalFileName;
  final String? note;

  bool get isFile =>
      kind == PetDocumentKind.file || kind == PetDocumentKind.image;
  bool get isImage => kind == PetDocumentKind.image;
  bool get isNote => kind == PetDocumentKind.note;

  String? get extension {
    final name = originalFileName ?? filePath;
    if (name == null) {
      return null;
    }
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    if (ext.isEmpty) {
      return null;
    }
    return ext;
  }

  File? get file => filePath == null ? null : File(filePath!);

  PetDocument copyWith({
    String? title,
    String? note,
    String? filePath,
    String? originalFileName,
    DateTime? updatedAt,
  }) {
    return PetDocument(
      id: id,
      petId: petId,
      title: title ?? this.title,
      kind: kind,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      filePath: filePath ?? this.filePath,
      originalFileName: originalFileName ?? this.originalFileName,
      note: note ?? this.note,
    );
  }

  factory PetDocument.fromStorage(Map<String, dynamic> json) {
    return PetDocument(
      id: json['id'] as String,
      petId: json['petId'] as String,
      title: json['title'] as String,
      kind: PetDocumentKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => PetDocumentKind.file,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      filePath: json['filePath'] as String?,
      originalFileName: json['originalFileName'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'kind': kind.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'filePath': filePath,
      'originalFileName': originalFileName,
      'note': note,
    };
  }
}
