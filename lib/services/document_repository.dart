import 'dart:io';

import 'package:flutter/foundation.dart';
import "package:hive/hive.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:uuid/uuid.dart";

import "../models/pet_document.dart";

class DocumentRepository extends ChangeNotifier {
  DocumentRepository();

  static const _boxName = "pet_diary_documents";
  static const _itemsKey = "items";
  static const _documentsFolder = "pet_documents";
  static final _uuid = const Uuid();

  late Box _box;
  List<PetDocument> _documents = const [];
  Directory? _storageDirectory;
  bool _initialized = false;
  Future<void>? _initFuture;

  List<PetDocument> get documents => List.unmodifiable(_documents);
  bool get isInitialized => _initialized;

  Future<void> init() {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    _box = await Hive.openBox(_boxName);
    _documents = (_box.get(_itemsKey) as List? ?? [])
        .whereType<Map>()
        .map(
          (raw) =>
              PetDocument.fromStorage(Map<String, dynamic>.from(raw as Map)),
        )
        .toList();
    await _ensureStorageDirectory();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await init();
  }

  Future<void> _ensureStorageDirectory() async {
    if (_storageDirectory != null) {
      return;
    }
    if (kIsWeb) {
      throw UnsupportedError('Document storage is not supported on web');
    }
    Directory baseDir;
    if (Platform.isIOS || Platform.isAndroid) {
      baseDir = await getApplicationSupportDirectory();
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }
    final dir = Directory(p.join(baseDir.path, _documentsFolder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _storageDirectory = dir;
  }

  Future<List<PetDocument>> documentsForPet(String petId) async {
    await _ensureInitialized();
    final list = _documents.where((doc) => doc.petId == petId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<PetDocument> createFileDocument({
    required String petId,
    required File source,
    required String displayName,
    required bool isImage,
  }) async {
    await _ensureInitialized();
    await _ensureStorageDirectory();
    final id = _uuid.v4();
    final extension = p.extension(source.path);
    final safeExtension = extension.isEmpty ? '' : extension.toLowerCase();
    final targetPath = p.join(_storageDirectory!.path, '$id$safeExtension');
    await source.copy(targetPath);
    final document = PetDocument(
      id: id,
      petId: petId,
      title: displayName,
      kind: isImage ? PetDocumentKind.image : PetDocumentKind.file,
      createdAt: DateTime.now(),
      filePath: targetPath,
      originalFileName: p.basename(source.path),
    );
    _documents = [..._documents, document];
    await _save();
    notifyListeners();
    return document;
  }

  Future<PetDocument> createNoteDocument({
    required String petId,
    required String title,
    required String note,
  }) async {
    await _ensureInitialized();
    final id = _uuid.v4();
    final document = PetDocument(
      id: id,
      petId: petId,
      title: title,
      kind: PetDocumentKind.note,
      createdAt: DateTime.now(),
      note: note,
    );
    _documents = [..._documents, document];
    await _save();
    notifyListeners();
    return document;
  }

  Future<void> updateDocument(PetDocument document) async {
    await _ensureInitialized();
    final index = _documents.indexWhere((item) => item.id == document.id);
    if (index == -1) {
      return;
    }
    final updatedList = [..._documents];
    updatedList[index] = document.copyWith(updatedAt: DateTime.now());
    _documents = updatedList;
    await _save();
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    await _ensureInitialized();
    PetDocument? document;
    for (final item in _documents) {
      if (item.id == id) {
        document = item;
        break;
      }
    }
    if (document == null) {
      return;
    }

    final updated = _documents.where((doc) => doc.id != id).toList();
    if (updated.length == _documents.length) {
      return;
    }
    _documents = updated;
    await _save();
    if (!kIsWeb && document.filePath != null) {
      final file = File(document.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    notifyListeners();
  }

  Future<void> deleteForPet(String petId) async {
    await _ensureInitialized();
    final toDelete = _documents.where((doc) => doc.petId == petId).toList();
    if (toDelete.isEmpty) {
      return;
    }
    _documents = _documents.where((doc) => doc.petId != petId).toList();
    await _save();
    for (final document in toDelete) {
      if (!kIsWeb && document.filePath != null) {
        final file = File(document.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    await _box.put(
      _itemsKey,
      _documents.map((doc) => doc.toStorage()).toList(),
    );
  }

  @override
  void dispose() {
    if (_box.isOpen) {
      _box.close();
    }
    super.dispose();
  }
}
