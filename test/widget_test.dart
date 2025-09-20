import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:hive/hive.dart";

import "package:pet_diary_app/main.dart";
import "package:pet_diary_app/services/pet_repository.dart";
import "package:pet_diary_app/services/reminder_repository.dart";
import "package:pet_diary_app/services/weight_repository.dart";
import "package:pet_diary_app/services/document_repository.dart";
import "package:pet_diary_app/services/notification_settings_repository.dart";
import "package:pet_diary_app/services/notification_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp("pet_diary_test_");
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets("Login screen renders welcoming UI", (tester) async {
    final petRepository = PetRepository();
    final reminderRepository = ReminderRepository();
    final weightRepository = WeightRepository();
    final documentRepository = DocumentRepository();
    final settingsRepository = NotificationSettingsRepository();
    final notificationService = NotificationService(
      reminders: reminderRepository,
      settings: settingsRepository,
    );

    await tester.pumpWidget(
      PetDiaryApp(
        petRepository: petRepository,
        reminderRepository: reminderRepository,
        weightRepository: weightRepository,
        documentRepository: documentRepository,
        settingsRepository: settingsRepository,
        notificationService: notificationService,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    expect(find.text("Sign in to your account"), findsOneWidget);
    expect(find.text("Continue"), findsOneWidget);
    expect(find.text("Continue as guest"), findsOneWidget);
  });
}
