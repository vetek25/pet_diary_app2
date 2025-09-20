import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:provider/provider.dart";

import "l10n/app_localizations.dart";
import "screens/add_pet_screen.dart";
import "screens/dashboard_screen.dart";
import "screens/documents_screen.dart";
import "screens/login_screen.dart";
import "screens/notification_settings_screen.dart";
import "screens/pet_card_screen.dart";
import "screens/splash_screen.dart";
import "services/document_repository.dart";
import "services/notification_service.dart";
import "services/notification_settings_repository.dart";
import "services/pet_repository.dart";
import "services/reminder_repository.dart";
import "services/weight_repository.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final petRepository = PetRepository();
  final reminderRepository = ReminderRepository();
  final weightRepository = WeightRepository();
  final documentRepository = DocumentRepository();
  final settingsRepository = NotificationSettingsRepository();
  final notificationService = NotificationService(
    reminders: reminderRepository,
    settings: settingsRepository,
  );

  runApp(
    PetDiaryApp(
      petRepository: petRepository,
      reminderRepository: reminderRepository,
      weightRepository: weightRepository,
      documentRepository: documentRepository,
      settingsRepository: settingsRepository,
      notificationService: notificationService,
    ),
  );
}

class PetDiaryApp extends StatelessWidget {
  const PetDiaryApp({
    super.key,
    required this.petRepository,
    required this.reminderRepository,
    required this.weightRepository,
    required this.documentRepository,
    required this.settingsRepository,
    required this.notificationService,
  });

  final PetRepository petRepository;
  final ReminderRepository reminderRepository;
  final WeightRepository weightRepository;
  final DocumentRepository documentRepository;
  final NotificationSettingsRepository settingsRepository;
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xFF1E3D59);
    const secondaryTextColor = Color(0xFF425466);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF6CC4A1),
          brightness: Brightness.light,
        ).copyWith(
          secondary: const Color(0xFF8AB6F9),
          tertiary: const Color(0xFFF5A8C7),
          background: const Color(0xFFF4F7F8),
          surface: Colors.white,
        );

    final baseTextTheme = ThemeData.light().textTheme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PetRepository>.value(value: petRepository),
        ChangeNotifierProvider<ReminderRepository>.value(
          value: reminderRepository,
        ),
        ChangeNotifierProvider<WeightRepository>.value(value: weightRepository),
        ChangeNotifierProvider<DocumentRepository>.value(
          value: documentRepository,
        ),
        ChangeNotifierProvider<NotificationSettingsRepository>.value(
          value: settingsRepository,
        ),
        ChangeNotifierProvider<NotificationService>.value(
          value: notificationService,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => context.l10n.appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.background,
          textTheme: baseTextTheme.copyWith(
            headlineSmall: baseTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
            titleLarge: baseTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(
              color: secondaryTextColor,
            ),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(
              color: secondaryTextColor,
            ),
            labelLarge: baseTextTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: primaryTextColor,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            margin: EdgeInsets.zero,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.55)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const SplashGate(),
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          DashboardScreen.routeName: (context) => const DashboardScreen(),
          DocumentsScreen.routeName: (context) => const DocumentsScreen(),
          PetCardScreen.routeName: (context) => const PetCardScreen(),
          AddPetScreen.routeName: (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments as AddPetScreenArgs?;
            return AddPetScreen(petId: args?.petId);
          },
        },
      ),
    );
  }
}
