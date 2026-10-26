import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/status_badge.dart';

class StaffWorkspacePage extends ConsumerWidget {
  const StaffWorkspacePage({super.key});

  Future<void> _call(
    BuildContext context,
    WidgetRef ref,
    String functionName,
    Map<String, dynamic> data,
  ) async {
    try {
      await FirebaseFunctions.instance.httpsCallable(functionName).call(data);
      ref.invalidate(appointmentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully.')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'The operation was rejected.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save changes: $e')),
        );
      }
    }
  }

  Future<void> _consult(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    Appointment appointment,
  ) async {
    final notes = TextEditingController();
    final diagnosis = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clinical consultation'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: diagnosis,
                  decoration: const InputDecoration(labelText: 'Diagnosis (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notes,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Clinical notes'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Clinical notes are required'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
            },
            child: const Text('Save notes'),
          ),
        ],
      ),
    );
    if (saved != true) {
      notes.dispose();
      diagnosis.dispose();
      return;
    }
    await _call(context, ref, 'saveConsultation', {
      'clinicId': user.clinicId,
      'appointmentId': appointment.id,
      'notes': notes.text.trim(),
      'diagnosis': diagnosis.text.trim(),
    });
    notes.dispose();
    diagnosis.dispose();
  }

  Future<void> _payment(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    Appointment appointment,
  ) async {
    final amount = TextEditingController(text: appointment.service.price.toStringAsFixed(2));
    String method = 'cash';
    final paid = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Record payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  DropdownMenuItem(value: 'insurance', child: Text('Insurance')),
                  DropdownMenuItem(value: 'transfer', child: Text('Bank transfer')),
                ],
                onChanged: (value) => setState(() => method = value ?? 'cash'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Record')),
          ],
        ),
      ),
    );
    if (paid == true) {
      final parsed = double.tryParse(amount.text.trim());
      if (parsed == null || parsed <= 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a valid positive amount.')),
          );
        }
      } else {
        await _call(context, ref, 'recordPayment', {
          'clinicId': user.clinicId,
          'appointmentId': appointment.id,
          'amount': parsed,
          'method': method,
        });
      }
    }
    amount.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Your staff profile is loading.')));
    }

    final isPatient = user.role == UserRole.patient;
    return Scaffold(
      appBar: AppBar(title: Text(isPatient ? 'My appointments' : '${user.role.name[0].toUpperCase()}${user.role.name.substring(1)} workspace')),
      body: ref.watch(appointmentsProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load appointments. Check your clinic assignment and Firestore permissions.\n$error', textAlign: TextAlign.center),
          ),
        ),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final actions = <Widget>[];
              if (user.role == UserRole.reception || user.role == UserRole.admin) {
                if (appointment.status == AppointmentStatus.scheduled) {
                  actions.add(OutlinedButton.icon(
                    onPressed: () => _call(context, ref, 'updateAppointmentStatus', {
                      'clinicId': user.clinicId, 'appointmentId': appointment.id, 'status': 'checkedIn',
                    }),
                    icon: const Icon(Icons.how_to_reg), label: const Text('Check in'),
                  ));
                }
              }
              if (user.role == UserRole.doctor || user.role == UserRole.admin) {
                if (appointment.status == AppointmentStatus.checkedIn) {
                  actions.add(OutlinedButton.icon(
                    onPressed: () => _call(context, ref, 'updateAppointmentStatus', {
                      'clinicId': user.clinicId, 'appointmentId': appointment.id, 'status': 'inConsultation',
                    }),
                    icon: const Icon(Icons.medical_services_outlined), label: const Text('Start consultation'),
                  ));
                }
                if (appointment.status == AppointmentStatus.inConsultation) {
                  actions.add(OutlinedButton.icon(
                    onPressed: () => _consult(context, ref, user, appointment),
                    icon: const Icon(Icons.note_alt_outlined), label: const Text('Clinical notes'),
                  ));
                  actions.add(OutlinedButton.icon(
                    onPressed: () => _call(context, ref, 'updateAppointmentStatus', {
                      'clinicId': user.clinicId, 'appointmentId': appointment.id, 'status': 'completed',
                    }),
                    icon: const Icon(Icons.check_circle_outline), label: const Text('Complete'),
                  ));
                }
              }
              if (user.role == UserRole.accountant || user.role == UserRole.reception || user.role == UserRole.admin) {
                actions.add(OutlinedButton.icon(
                  onPressed: () => _payment(context, ref, user, appointment),
                  icon: const Icon(Icons.payments_outlined), label: const Text('Record payment'),
                ));
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(appointment.service.name, style: Theme.of(context).textTheme.titleMedium)),
                        StatusBadge(appointment.status),
                      ]),
                      const SizedBox(height: 8),
                      Text('Doctor: ${appointment.doctor.name}'),
                      Text('Date: ${appointment.date.day.toString().padLeft(2, '0')}/${appointment.date.month.toString().padLeft(2, '0')}/${appointment.date.year} · ${appointment.startTime}'),
                      Text('Reference: ${appointment.number}'),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: actions),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
