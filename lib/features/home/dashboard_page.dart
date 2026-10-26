import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final role = user?.role ?? UserRole.patient;
    final isPatient = role == UserRole.patient;
    final title = user?.name.isNotEmpty == true ? user!.name : 'ClinicFlow';
    final actions = <_DashboardAction>[
      if (isPatient)
        _DashboardAction('Book appointment', Icons.add_circle_outline, () => context.push('/book')),
      _DashboardAction(
        isPatient ? 'My appointments' : 'Appointments workspace',
        Icons.calendar_month,
        () => context.push(isPatient ? '/appointments' : '/staff'),
      ),
      if (!isPatient)
        _DashboardAction('Staff operations', Icons.medical_services_outlined, () => context.push('/staff')),
      _DashboardAction('My profile', Icons.person_outline, () => context.push('/profile')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClinicFlow'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Welcome, $title', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            isPatient ? 'Your care at a glance' : '${role.name[0].toUpperCase()}${role.name.substring(1)} workspace',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPatient ? 'Your appointments' : 'Clinic operations', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ref.watch(appointmentsProvider).when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Appointment summary is unavailable. Open the workspace to check permissions.'),
                    data: (appointments) => Text(
                      isPatient
                          ? (appointments.isEmpty ? 'No upcoming appointments yet.' : 'You have ${appointments.length} appointment(s).')
                          : '${appointments.length} appointment(s) in your clinic.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(isPatient
                      ? 'Book a visit or review your existing appointments.'
                      : 'Manage check-in, consultations, clinical notes and payments according to your role.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((action) => _ActionCard(action: action)).toList(),
          ),
          if (role == UserRole.admin) ...[
            const SizedBox(height: 20),
            const Card(
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined),
                title: Text('Administrator access'),
                subtitle: Text('Manage doctors and services through trusted clinic administration tools. Staff roles are assigned by server-side provisioning.'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _DashboardAction action;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 164,
        height: 112,
        child: Card(
          child: InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(action.icon),
                  const Spacer(),
                  Text(action.label),
                ],
              ),
            ),
          ),
        ),
      );
}
