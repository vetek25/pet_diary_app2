export 'api_client.dart' show ApiException;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/pet.dart';
import '../models/pet_document.dart';
import '../models/reminder.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import 'api_client.dart';
import 'document_repository.dart';
import 'notification_settings_repository.dart';
import 'pet_repository.dart';
import 'reminder_repository.dart';
import 'sync_service.dart';
import 'user_repository.dart';
import 'weight_repository.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository({
    required this.apiClient,
    required FlutterSecureStorage secureStorage,
    required this.userRepository,
    required this.notificationSettingsRepository,
    required this.petRepository,
    required this.reminderRepository,
    required this.documentRepository,
    required this.weightRepository,
    required this.syncService,
  }) : _secureStorage = secureStorage;

  static const _tokenKey = 'auth_token';

  final ApiClient apiClient;
  final FlutterSecureStorage _secureStorage;
  final UserRepository userRepository;
  final NotificationSettingsRepository notificationSettingsRepository;
  final PetRepository petRepository;
  final ReminderRepository reminderRepository;
  final DocumentRepository documentRepository;
  final WeightRepository weightRepository;
  final SyncService syncService;

  String? _token;
  bool _loading = false;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _loading;

  Future<void> init() async {
    _token = await _secureStorage.read(key: _tokenKey);
    apiClient.updateToken(_token);
    if (_token != null && _token!.isNotEmpty) {
      try {
        await fetchProfile();
      } catch (_) {
        await logout();
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String fullName,
    String? phone,
    String? address,
    String? localeCode,
  }) async {
    final resolvedLocale = localeCode ?? userRepository.profile.localeCode;
    await apiClient.post(
      '/api/register.php',
      body: {
        'email': email,
        'password': password,
        'display_name': displayName,
        'full_name': fullName,
        'phone': phone ?? '',
        'address': address ?? '',
        'locale_code': resolvedLocale,
      },
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await apiClient.post(
      '/api/verify_email.php',
      body: {'email': email, 'code': code},
    );
  }

  Future<void> resendVerificationCode({required String email}) async {
    await apiClient.post('/api/resend_code.php', body: {'email': email});
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final response = await apiClient.post(
        '/api/login.php',
        body: {'email': email, 'password': password},
      );
      final token = response['token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('Token missing in response');
      }
      await _storeToken(token);
      await fetchProfile();
      await syncService.pushLocalState();
      await fetchProfile();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    Map<String, dynamic> data;
    try {
      data = await apiClient.get('/api/me.php');
    } on ApiException catch (error) {
      if (kDebugMode) {
        debugPrint('AuthRepository.fetchProfile error: ' + jsonEncode({'status': error.statusCode, 'message': error.message, 'details': error.details}));
      }
      if (error.statusCode == 401) {
        await logout();
      }
      rethrow;
    }

    final profile = UserProfile.fromBackend(data);
    await userRepository.applyRemote(profile);
    if (kDebugMode) {
      debugPrint('AuthRepository.fetchProfile: user ' + jsonEncode(profile.toBackend()));
      debugPrint('AuthRepository.fetchProfile: pets raw = ' + jsonEncode(data['pets'] ?? 'null'));
      debugPrint('AuthRepository.fetchProfile: reminders raw = ' + jsonEncode(data['reminders'] ?? 'null'));
    }

    final settingsMap = _ensureMap(data['settings']);
    if (settingsMap.isNotEmpty) {
      await notificationSettingsRepository.update(
        enabled: _parseBool(settingsMap['enabled']),
        silentMode: _parseBool(
          settingsMap['silent_mode'] ?? settingsMap['silentMode'],
        ),
        duplicateEmail: _parseBool(
          settingsMap['duplicate_email'] ?? settingsMap['duplicateEmail'],
        ),
        receiveReminders: _parseBool(
          settingsMap['receive_reminders'] ?? settingsMap['receiveReminders'],
        ),
        receiveClinic: _parseBool(
          settingsMap['receive_clinic'] ?? settingsMap['receiveClinic'],
        ),
        receiveBilling: _parseBool(
          settingsMap['receive_billing'] ?? settingsMap['receiveBilling'],
        ),
      );
    }

    if (data['pets'] is List) {
      final pets = _parsePets(data['pets']);
      await petRepository.replaceAll(pets);
    } else {
      await petRepository.replaceAll(const <Pet>[]);
    }

    if (data['reminders'] is List) {
      final reminders = _parseReminders(data['reminders']);
      await reminderRepository.replaceAll(reminders);
    } else {
      await reminderRepository.replaceAll(const <Reminder>[]);
    }

    if (data['documents'] is List) {
      final documents = _parseDocuments(data['documents']);
      await documentRepository.replaceAll(documents);
    } else {
      await documentRepository.replaceAll(const <PetDocument>[]);
    }

    if (data['weights'] is Map) {
      final weights = _parseWeights(data['weights']);
      await weightRepository.replaceAll(weights);
    } else {
      await weightRepository.replaceAll(<String, List<WeightEntry>>{});
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    apiClient.updateToken(null);
    await _secureStorage.delete(key: _tokenKey);
    await userRepository.reset();
    await petRepository.replaceAll(const <Pet>[]);
    await reminderRepository.replaceAll(const <Reminder>[]);
    await documentRepository.replaceAll(const <PetDocument>[]);
    await weightRepository.replaceAll(<String, List<WeightEntry>>{});
    notifyListeners();
  }

  Future<void> _storeToken(String token) async {
    _token = token;
    apiClient.updateToken(token);
    await _secureStorage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_loading == value) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  Map<String, dynamic> _ensureMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  List<Pet> _parsePets(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map((raw) => Pet.fromStorage(Map<String, dynamic>.from(raw)))
        .toList();
  }

  List<Reminder> _parseReminders(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map((raw) => Reminder.fromStorage(Map<String, dynamic>.from(raw)))
        .toList();
  }

  List<PetDocument> _parseDocuments(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map((raw) => PetDocument.fromStorage(Map<String, dynamic>.from(raw)))
        .toList();
  }

  Map<String, List<WeightEntry>> _parseWeights(dynamic value) {
    final result = <String, List<WeightEntry>>{};
    if (value is! Map) {
      return result;
    }
    final map = Map<String, dynamic>.from(value);
    for (final entry in map.entries) {
      final list = entry.value;
      if (list is List) {
        result[entry.key] = list
            .whereType<Map>()
            .map(
              (raw) => WeightEntry.fromStorage(Map<String, dynamic>.from(raw)),
            )
            .toList();
      }
    }
    return result;
  }

  bool? _parseBool(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return null;
  }
}
