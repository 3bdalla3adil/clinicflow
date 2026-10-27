import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String? _loadedUserId;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _loadUser(AppUser user) {
    if (_loadedUserId == user.id) return;
    _loadedUserId = user.id;
    _name.text = user.name == 'Guest patient' ? '' : user.name;
    _email.text = user.email;
    _phone.text = user.phone;
  }

  Future<void> _save(AppUser user) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await FirebaseFunctions.instance.httpsCallable('updateGuestProfile').call({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
      });
      ref.invalidate(currentUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? 'Unable to save your profile.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to save your profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(clinicRepositoryProvider).signOut();
    ref.read(demoModeProvider.notifier).state = false;
    ref.invalidate(currentUserProvider);
    ref.invalidate(appointmentsProvider);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    _loadUser(user);
    final canEdit = user.role == UserRole.patient && !ref.watch(demoModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36))),
          const SizedBox(height: 20),
          if (user.isGuest || !user.profileComplete)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'You can book as a guest. Complete your name and contact details when you are ready so the clinic can contact you about your appointment.',
                ),
              ),
            ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  readOnly: !canEdit,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => canEdit && (value == null || value.trim().isEmpty)
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  readOnly: !canEdit,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Contact email (optional)'),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (canEdit && email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  readOnly: !canEdit,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number (recommended)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: user.role.name,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (canEdit) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : () => _save(user),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save my information'),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
