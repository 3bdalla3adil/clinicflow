import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});
  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  Doctor? doctor;
  MedicalService? service;
  DateTime date = DateTime.now();
  String time = '10:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('1. Select service'),
          const SizedBox(height: 8),
          ref.watch(servicesProvider).when(
            data: (xs) => DropdownButtonFormField<MedicalService>(
              value: service,
              items: xs.map((x) => DropdownMenuItem(value: x, child: Text('\${x.name} · \${x.price.toStringAsFixed(0)}'))).toList(),
              onChanged: (x) => setState(() => service = x),
              decoration: const InputDecoration(labelText: 'Service'),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Unable to load services: $e'),
          ),
          const SizedBox(height: 20),
          const Text('2. Select doctor'),
          const SizedBox(height: 8),
          ref.watch(doctorsProvider).when(
            data: (xs) => DropdownButtonFormField<Doctor>(
              value: doctor,
              items: xs.map((x) => DropdownMenuItem(value: x, child: Text('\${x.name} · \${x.specialty}'))).toList(),
              onChanged: (x) => setState(() => doctor = x),
              decoration: const InputDecoration(labelText: 'Doctor'),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Unable to load doctors: $e'),
          ),
          const SizedBox(height: 20),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Date'), subtitle: Text('\${date.day}/\${date.month}/\${date.year}'), trailing: OutlinedButton(onPressed: () async { final selected = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)), initialDate: date); if (selected != null) setState(() => date = selected); }, child: const Text('Choose'))),
          const SizedBox(height: 8),
          const Text('4. Available time'),
          Wrap(spacing: 8, runSpacing: 8, children: ['09:00', '10:00', '11:00', '14:00'].map<Widget>((x) => ChoiceChip(label: Text(x), selected: x == time, onSelected: (_) => setState(() => time = x))).toList()),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: doctor == null || service == null ? null : () async {
              final appointment = await ref.read(clinicRepositoryProvider).createAppointment(doctor: doctor!, service: service!, date: date, startTime: time);
              if (!context.mounted) return;
              await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Appointment confirmed'), content: Text('\${appointment.number}\n\${appointment.doctor.name}\n\${appointment.service.name}\n\${appointment.startTime}'), actions: [TextButton(onPressed: () => context.go('/appointments'), child: const Text('View appointments'))]));
            },
            child: const Text('Confirm appointment'),
          ),
        ],
      ),
    );
  }
}