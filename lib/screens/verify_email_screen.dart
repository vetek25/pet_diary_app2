import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../services/auth_repository.dart';

import 'login_screen.dart';



class VerifyEmailScreen extends StatefulWidget {

  const VerifyEmailScreen({super.key});



  static const routeName = '/verify-email';



  @override

  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();

}



class _VerifyEmailScreenState extends State<VerifyEmailScreen> {

  final _codeController = TextEditingController();

  bool _submitting = false;

  late String _email;

  bool _emailResolved = false;



  @override

  void didChangeDependencies() {

    super.didChangeDependencies();

    if (_emailResolved) {

      return;

    }

    final args = ModalRoute.of(context)?.settings.arguments;

    _email = (args is String && args.isNotEmpty) ? args : '';

    _emailResolved = true;

  }



  @override

  void dispose() {

    _codeController.dispose();

    super.dispose();

  }



  Future<void> _verify() async {

    if (_email.isEmpty) {

      _showMessage('Email is missing. Please register again.');

      return;

    }

    final code = _codeController.text.trim();

    if (code.length < 4) {

      _showMessage('Enter the verification code.');

      return;

    }

    setState(() => _submitting = true);

    final auth = context.read<AuthRepository>();

    try {

      await auth.verifyEmail(email: _email, code: code);

      if (!mounted) {

        return;

      }

      _showMessage('Email verified. You can log in now.');

      Navigator.pushNamedAndRemoveUntil(

        context,

        LoginScreen.routeName,

        (_) => false,

      );

    } on ApiException catch (error) {

      _showMessage(error.message);

    } catch (error) {

      _showMessage('Verification failed: $error');

    } finally {

      if (mounted) {

        setState(() => _submitting = false);

      }

    }

  }



  Future<void> _resend() async {

    if (_email.isEmpty) {

      _showMessage('Email is missing. Please register again.');

      return;

    }

    final auth = context.read<AuthRepository>();

    try {

      await auth.resendVerificationCode(email: _email);

      _showMessage('Verification code resent.');

    } on ApiException catch (error) {

      _showMessage(error.message);

    } catch (error) {

      _showMessage('Failed to resend code: $error');

    }

  }



  void _showMessage(String message) {

    ScaffoldMessenger.of(

      context,

    ).showSnackBar(SnackBar(content: Text(message)));

  }



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);



    return Scaffold(

      appBar: AppBar(title: const Text('Verify email')),

      body: Padding(

        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              'Enter the code we sent to $_email\n',

              style: theme.textTheme.titleLarge,

            ),

            const SizedBox(height: 24),

            TextField(

              controller: _codeController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: 'Verification code'),

            ),

            const SizedBox(height: 24),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: _submitting ? null : _verify,

                child: _submitting

                    ? const SizedBox(

                        height: 18,

                        width: 18,

                        child: CircularProgressIndicator(strokeWidth: 2),

                      )

                    : const Text('Verify'),

              ),

            ),

            const SizedBox(height: 12),

            TextButton(

              onPressed: _submitting ? null : _resend,

              child: const Text('Resend code'),

            ),

          ],

        ),

      ),

    );

  }

}









