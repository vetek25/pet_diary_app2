import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../l10n/app_localizations.dart";
import "../services/auth_repository.dart";
import "dashboard_screen.dart";
import "register_screen.dart";
import "verify_email_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openDashboard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthRepository>();
    try {
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    } on ApiException catch (error) {
      final details = error.details;
      if (details != null && details['need_verify'] == true) {
        if (!mounted) {
          return;
        }
        _showMessage(error.message);
        Navigator.pushReplacementNamed(
          context,
          VerifyEmailScreen.routeName,
          arguments: _emailController.text.trim(),
        );
      } else {
        _showMessage(error.message);
      }
    } catch (error) {
      _showMessage('Login failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _continueAsGuest() async {
    final auth = context.read<AuthRepository>();
    await auth.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -60,
            child: _DecorativeCircle(
              size: 220,
              color: colorScheme.primary.withOpacity(0.15),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: _DecorativeCircle(
              size: 180,
              color: colorScheme.tertiary.withOpacity(0.15),
            ),
          ),
          Positioned(
            top: 120,
            right: -40,
            child: _DecorativeCircle(
              size: 120,
              color: colorScheme.secondary.withOpacity(0.12),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withOpacity(0.22),
                              colorScheme.secondary.withOpacity(0.16),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(
                                      0.28,
                                    ),
                                    offset: const Offset(0, 10),
                                    blurRadius: 32,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 34,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              l10n.loginWelcomeTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: 28,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.loginWelcomeDescription,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.loginSignIn,
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: l10n.loginEmailLabel,
                                  hintText: l10n.loginEmailHint,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.loginEmailHint;
                                  }
                                  if (!value.contains('@')) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.loginPasswordLabel,
                                  hintText: l10n.loginPasswordHint,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                validator: (value) =>
                                    value == null || value.length < 6
                                    ? 'Min 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(l10n.loginForgotPassword),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _isSubmitting
                                    ? null
                                    : _openDashboard,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.favorite_outline),
                                label: Text(l10n.loginContinue),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outline.withOpacity(
                                        0.25,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(l10n.loginOr),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outline.withOpacity(
                                        0.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              OutlinedButton.icon(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _showMessage(
                                        'Google sign-in is not implemented yet.',
                                      ),
                                icon: const Icon(Icons.g_translate),
                                label: Text(l10n.loginContinueWithGoogle),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  side: BorderSide(
                                    color: colorScheme.primary.withOpacity(
                                      0.35,
                                    ),
                                  ),
                                ),
                              ),
                              if (isIOS) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => _showMessage(
                                          'Apple sign-in is not implemented yet.',
                                        ),
                                  icon: const Icon(Icons.apple),
                                  label: Text(l10n.loginContinueWithApple),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    side: BorderSide(
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pushReplacementNamed(
                                        context,
                                        RegisterScreen.routeName,
                                      ),
                                child: const Text('Create an account'),
                              ),
                              TextButton(
                                onPressed: _isSubmitting ? null : _continueAsGuest,
                                child: const Text('Continue as guest'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
