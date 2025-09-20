import '../models/pet.dart';
import '../models/pet_document.dart';
import '../models/reminder.dart';
import 'api_client.dart';
import 'document_repository.dart';
import 'notification_settings_repository.dart';
import 'pet_repository.dart';
import 'reminder_repository.dart';
import 'user_repository.dart';
import 'weight_repository.dart';

class SyncService {
  SyncService({
    required this.apiClient,
    required this.userRepository,
    required this.notificationSettingsRepository,
    required this.petRepository,
    required this.reminderRepository,
    required this.documentRepository,
    required this.weightRepository,
  });

  final ApiClient apiClient;
  final UserRepository userRepository;
  final NotificationSettingsRepository notificationSettingsRepository;
  final PetRepository petRepository;
  final ReminderRepository reminderRepository;
  final DocumentRepository documentRepository;
  final WeightRepository weightRepository;

  Future<void> pushLocalState() async {
    final payload = <String, dynamic>{
      'profile': userRepository.profile.toBackend(),
      'settings': {
        'enabled': notificationSettingsRepository.enabled,
        'silent_mode': notificationSettingsRepository.silentMode,
        'duplicate_email': notificationSettingsRepository.duplicateEmail,
        'receive_reminders': notificationSettingsRepository.receiveReminders,
        'receive_clinic': notificationSettingsRepository.receiveClinic,
        'receive_billing': notificationSettingsRepository.receiveBilling,
      },
      'pets': petRepository.pets.map<Map<String, dynamic>>((Pet pet) => pet.toStorage()).toList(),
      'reminders': reminderRepository.reminders
          .map<Map<String, dynamic>>((Reminder reminder) => reminder.toStorage())
          .toList(),
      'documents': documentRepository.documents
          .map<Map<String, dynamic>>((PetDocument document) => document.toStorage())
          .toList(),
      'weights': weightRepository.exportStorageMap(),
    };

    try {
      await apiClient.post('/api/sync.php', body: payload);
    } on ApiException {
      // Ignore sync failures for now. They can be retried later.
    }
  }
}
