import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';

class UserRepository extends ChangeNotifier {
  UserRepository();

  static const _boxName = 'pet_diary_user';
  static const _profileKey = 'profile';
  static const _profileFolder = 'user_profile';

  static const UserProfile _defaultProfile = UserProfile();

  late Box _box;
  UserProfile _profile = _defaultProfile;
  Directory? _storageDirectory;
  bool _initialized = false;
  Future<void>? _initFuture;

  UserProfile get profile => _profile;
  Locale get locale => Locale(
        _profile.localeCode.isEmpty ? 'en' : _profile.localeCode,
      );
  bool get isInitialized => _initialized;

  void prefillLocale(Locale deviceLocale, Iterable<Locale> supportedLocales) {
    if (_initialized) {
      return;
    }
    final targetCode = deviceLocale.languageCode;
    for (final locale in supportedLocales) {
      if (locale.languageCode == targetCode) {
        if (_profile.localeCode != targetCode) {
          _profile = _profile.copyWith(localeCode: targetCode);
        }
        return;
      }
    }
  }

  Future<void> init() {
    _initFuture ??= _initInternal();
    return _initFuture!;
  }

  Future<void> _initInternal() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box.get(_profileKey);
    if (stored is Map) {
      _profile = UserProfile.fromStorage(Map<String, dynamic>.from(stored));
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await init();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _ensureInitialized();
    _profile = profile;
    await _save();
    notifyListeners();
  }

  Future<void> applyRemote(UserProfile profile) async {
    await _ensureInitialized();
    _profile = profile;
    await _save();
    notifyListeners();
  }

  Future<void> updateFields({
    int? id,
    String? plan,
    bool? isActive,
    bool? isVerified,
    String? displayName,
    String? fullName,
    String? address,
    String? email,
    String? phone,
    String? localeCode,
    String? avatarPath,
    bool clearAvatar = false,
  }) async {
    await _ensureInitialized();
    _profile = _profile.copyWith(
      id: id,
      plan: plan,
      isActive: isActive,
      isVerified: isVerified,
      displayName: displayName,
      fullName: fullName,
      address: address,
      email: email,
      phone: phone,
      localeCode: localeCode,
      avatarPath: avatarPath,
      clearAvatarPath: clearAvatar,
    );
    await _save();
    notifyListeners();
  }

  Future<void> updateLocale(String localeCode) =>
      updateFields(localeCode: localeCode);

  Future<void> updateAvatar(File file) async {
    if (kIsWeb) {
      throw UnsupportedError('Avatar updates are not supported on web yet.');
    }
    await _ensureInitialized();
    await _ensureStorageDirectory();
    final extension = p.extension(file.path).toLowerCase();
    final sanitizedExtension = extension.isEmpty ? '.png' : extension;
    final targetPath = p.join(
      _storageDirectory!.path,
      'avatar$sanitizedExtension',
    );
    final previousAvatar = _profile.avatarPath;
    if (previousAvatar != null) {
      final previousFile = File(previousAvatar);
      if (await previousFile.exists()) {
        await previousFile.delete();
      }
    }
    await file.copy(targetPath);
    await updateFields(avatarPath: targetPath);
  }

  Future<void> clearAvatar() async {
    await _ensureInitialized();
    final avatarPath = _profile.avatarPath;
    if (!kIsWeb && avatarPath != null) {
      final file = File(avatarPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await updateFields(clearAvatar: true);
  }

  Future<void> reset() async {
    await _ensureInitialized();
    if (!kIsWeb) {
      final avatarPath = _profile.avatarPath;
      if (avatarPath != null) {
        final file = File(avatarPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    _profile = _defaultProfile;
    if (_box.isOpen) {
      await _box.delete(_profileKey);
    }
    notifyListeners();
  }

  Future<void> _ensureStorageDirectory() async {
    if (_storageDirectory != null) {
      return;
    }
    if (kIsWeb) {
      return;
    }
    Directory baseDir;
    if (Platform.isIOS || Platform.isAndroid) {
      baseDir = await getApplicationSupportDirectory();
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }
    final dir = Directory(p.join(baseDir.path, _profileFolder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _storageDirectory = dir;
  }

  Future<void> _save() async {
    await _box.put(_profileKey, _profile.toStorage());
  }

  @override
  void dispose() {
    if (!_initialized) {
      super.dispose();
      return;
    }
    if (_box.isOpen) {
      _box.close();
    }
    super.dispose();
  }
}
