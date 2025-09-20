import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../services/pet_repository.dart";
import "../services/reminder_repository.dart";
import "../services/document_repository.dart";
import "../services/weight_repository.dart";
import "../services/notification_settings_repository.dart";
import "../services/notification_service.dart";
import "login_screen.dart";

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  late Future<void> _loadingFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final petRepository = context.read<PetRepository>();
    final reminderRepository = context.read<ReminderRepository>();
    final documentRepository = context.read<DocumentRepository>();
    final weightRepository = context.read<WeightRepository>();
    final settingsRepository = context.read<NotificationSettingsRepository>();
    final notificationService = context.read<NotificationService>();
    _loadingFuture = _initialize(
      petRepository,
      reminderRepository,
      documentRepository,
      weightRepository,
      settingsRepository,
      notificationService,
    );
    _initialized = true;
  }

  Future<void> _initialize(
    PetRepository petRepository,
    ReminderRepository reminderRepository,
    DocumentRepository documentRepository,
    WeightRepository weightRepository,
    NotificationSettingsRepository settingsRepository,
    NotificationService notificationService,
  ) async {
    await Future.wait([
      petRepository.init(),
      reminderRepository.init(),
      documentRepository.init(),
      weightRepository.init(),
      settingsRepository.init(),
    ]);
    await notificationService.init();
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const LoginScreen();
        }
        return const SplashScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBEE7FE), Color(0xFFF6F7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const _AnimalComposition(),
                const SizedBox(height: 40),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    color: const Color(0xFF17475A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    l10n.splashTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF3B6271),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF6CC4A1)),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 18,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Powered by care",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF558592),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalComposition extends StatelessWidget {
  const _AnimalComposition();

  @override
  Widget build(BuildContext context) {
    final palette = [
      const Color(0xFF6CC4A1),
      const Color(0xFF8AB6F9),
      const Color(0xFFF8C490),
      const Color(0xFFFF9EC7),
    ];

    return SizedBox(
      height: 320,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  palette[0].withOpacity(0.35),
                  palette[1].withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(160),
              boxShadow: [
                BoxShadow(
                  color: palette[1].withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 30),
                ),
              ],
            ),
          ),
          const Positioned(left: 46, bottom: 56, child: _DogFigure()),
          const Positioned(right: 40, bottom: 54, child: _CatFigure()),
          const _FloatingItem(
            icon: Icons.ramen_dining,
            top: 10,
            right: 80,
            background: Color(0xFFFFEDD6),
            foreground: Color(0xFFEC9A5D),
            rotation: -0.18,
          ),
          const _FloatingItem(
            icon: Icons.medication_outlined,
            top: 100,
            left: 24,
            background: Color(0xFFE9F6FF),
            foreground: Color(0xFF5E9EE6),
            rotation: 0.12,
          ),
          const _FloatingItem(
            icon: Icons.vaccines,
            top: 200,
            right: 24,
            background: Color(0xFFEAFBF3),
            foreground: Color(0xFF44B487),
            rotation: -0.1,
          ),
          const _FloatingItem(
            icon: Icons.calendar_month,
            bottom: 32,
            left: 40,
            background: Color(0xFFFFF2F6),
            foreground: Color(0xFFEF6686),
            rotation: 0.16,
          ),
          const _FloatingItem(
            icon: Icons.medical_services_outlined,
            bottom: 6,
            right: 70,
            background: Color(0xFFF1F4FF),
            foreground: Color(0xFF6B79FF),
            rotation: -0.12,
          ),
        ],
      ),
    );
  }
}

class _DogFigure extends StatelessWidget {
  const _DogFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: 12,
            child: Container(
              width: 104,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD7B0),
                borderRadius: BorderRadius.circular(60),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33BC6C25),
                    blurRadius: 18,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 48,
            top: -8,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5C9),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: -26,
            child: Transform.rotate(
              angle: -0.6,
              child: Container(
                width: 30,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F602E),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 86,
            top: -26,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 30,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F602E),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 60,
            top: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Align(
                alignment: Alignment(0, 0.4),
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFF6C4730),
                ),
              ),
            ),
          ),
          Positioned(
            left: 72,
            top: 34,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF6C4730),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 40,
            top: 48,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF6C4730),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 92,
            top: 48,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF6C4730),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatFigure extends StatelessWidget {
  const _CatFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: 18,
            child: Container(
              width: 88,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E4FF),
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x306178FF),
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 42,
            top: -6,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4FF),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 32,
            top: -18,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 26,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8AA1F8),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 78,
            top: -18,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 26,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8AA1F8),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 46,
            top: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF465897),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 70,
            top: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF465897),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 58,
            top: 42,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE75F8B),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 54,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF465897),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 88,
            top: 54,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF465897),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingItem extends StatelessWidget {
  const _FloatingItem({
    required this.icon,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.background,
    required this.foreground,
    this.rotation = 0,
  });

  final IconData icon;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color background;
  final Color foreground;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: foreground.withOpacity(0.18),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(icon, color: foreground, size: 28),
        ),
      ),
    );
  }
}
