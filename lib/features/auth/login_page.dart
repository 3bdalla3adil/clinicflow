import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/repositories/clinic_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(clinicRepositoryProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      ref.invalidate(currentUserProvider);
      await ref.read(currentUserProvider.future);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(clinicRepositoryProvider).signInWithGoogle();
      ref.invalidate(currentUserProvider);
      await ref.read(currentUserProvider.future);
      if (!mounted) return;
      context.go('/dashboard');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'web-context-cancelled') {
        return;
      }
      setState(() => _error = switch (error.code) {
        'account-exists-with-different-credential' =>
          'An account already exists with a different sign-in method.',
        'network-request-failed' =>
          'Network unavailable. Check your connection and try again.',
        'user-disabled' => 'This account has been disabled. Contact the clinic.',
        _ => 'Google sign-in failed. Please try again.',
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    // Password recovery has its own explicit email input. Signing in never
    // triggers this operation and no demo/test email is ever substituted.
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: resetEmailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'name@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(resetEmailController.text.trim()),
            child: const Text('Send reset email'),
          ),
        ],
      ),
    );
    resetEmailController.dispose();
    if (!mounted || email == null) return;

    final normalizedEmail = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
        .hasMatch(normalizedEmail)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(clinicRepositoryProvider).sendPasswordReset(normalizedEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If an account exists for this address, a password reset email will be sent.',
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = switch (error.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-not-found' =>
          'No ClinicFlow account was found for that email address.',
        'network-request-failed' =>
          'Network unavailable. Check your connection and try again.',
        'too-many-requests' =>
          'Too many attempts. Please wait before requesting another email.',
        _ => 'Unable to send the reset email. Please try again.',
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Unable to send the reset email: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _tryDemo() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      ref.read(demoModeProvider.notifier).state = true;
      final repository = ref.read(clinicRepositoryProvider);
      if (repository is! DemoClinicRepository) {
        throw StateError('Failed to enter isolated demo mode.');
      }
      await repository.signInAsDemoGuest();
      ref.invalidate(currentUserProvider);
      await ref.read(currentUserProvider.future);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (error) {
      ref.read(demoModeProvider.notifier).state = false;
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAvailable = ref.watch(firebaseAvailableProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(alignment: AlignmentDirectional.centerEnd, child: IconButton(tooltip: 'Settings', onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined))),
                    const Text(
                      'ClinicFlow',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(value.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password is required'
                          : null,
                      onFieldSubmitted: (_) {
                        if (!_loading && firebaseAvailable) _signIn();
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading || !firebaseAvailable ? null : _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    if (!firebaseAvailable) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Firebase is not configured in this build. Email sign-in, Google sign-in, password reset, and guest booking are unavailable. Use Try Demo or rebuild with the Firebase Android/iOS configuration.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading || !firebaseAvailable ? null : _signIn,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _loading || !firebaseAvailable ? null : () => context.push('/guest'),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Continue as guest'),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loading || !firebaseAvailable ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _loading ? null : _tryDemo,
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Try Demo — no account needed'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
