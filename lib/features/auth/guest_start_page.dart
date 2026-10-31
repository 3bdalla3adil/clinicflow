import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class GuestStartPage extends ConsumerStatefulWidget {
  const GuestStartPage({super.key});

  @override
  ConsumerState<GuestStartPage> createState() => _GuestStartPageState();
}

class _GuestStartPageState extends ConsumerState<GuestStartPage> {
  List<Map<String, dynamic>> _clinics = const [];
  String? _selectedClinicId;
  String? _error;
  bool _loading = true;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('listPublicClinics')
          .call<Map<String, dynamic>>();
      final raw = result.data['clinics'];
      final clinics = raw is List
          ? raw.whereType<Map>().map((clinic) => Map<String, dynamic>.from(clinic)).toList()
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _clinics = clinics;
        _selectedClinicId = clinics.isEmpty ? null : clinics.first['id'] as String?;
        _loading = false;
        _error = clinics.isEmpty
            ? 'No clinics are accepting online bookings yet. Please sign in or contact the clinic.'
            : null;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message ?? 'Unable to load clinics. Please try again later.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load clinics. Please check your connection and try again.';
      });
    }
  }

  Future<void> _continueAsGuest() async {
    final clinicId = _selectedClinicId;
    if (clinicId == null) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      await ref.read(clinicRepositoryProvider).startGuestSession(clinicId);
      ref.read(demoModeProvider.notifier).state = false;
      ref.invalidate(currentUserProvider);
      ref.invalidate(doctorsProvider);
      ref.invalidate(servicesProvider);
      ref.invalidate(appointmentsProvider);
      // Wait for the profile stream to observe the callable-created guest
      // document before navigating to authenticated screens.
      await ref.read(currentUserProvider.future);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Guest access could not be started: $e');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(\n        title: const Text('Continue as guest'),\n        leading: IconButton(\n          tooltip: 'Back to sign in',\n          onPressed: _starting ? null : () => context.go('/login'),\n          icon: const Icon(Icons.arrow_back),\n        ),\n      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Icon(Icons.health_and_safety_outlined, size: 56),
              const SizedBox(height: 16),
              Text('Book first, complete your profile later',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'You can start without creating a password. Your guest session is saved on this device. Add your name and contact details later from My Profile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_clinics.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _selectedClinicId,
                  decoration: const InputDecoration(
                    labelText: 'Choose clinic',
                    border: OutlineInputBorder(),
                  ),
                  items: _clinics.map((clinic) {
                    final id = clinic['id'] as String;
                    final name = clinic['name'] as String? ?? 'Clinic';
                    final city = clinic['city'] as String? ?? '';
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(city.isEmpty ? name : '$name · $city',
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: _starting
                      ? null
                      : (value) => setState(() => _selectedClinicId = value),
                ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                if (!_loading && _clinics.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _loadClinics,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading || _starting || _selectedClinicId == null
                    ? null
                    : _continueAsGuest,
                child: _starting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue as guest'),
              ),
              TextButton(
                onPressed: _starting ? null : () => context.go('/login'),
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
