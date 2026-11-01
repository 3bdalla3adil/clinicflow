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
  AppointmentSlot? selectedSlot;
  Future<List<AppointmentSlot>>? availabilityFuture;
  bool submitting = false;

  String _datePart(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  void _refreshAvailability() {
    setState(() {
      selectedSlot = null;
      final selectedDoctor = doctor;
      final selectedService = service;
      availabilityFuture = selectedDoctor == null || selectedService == null
          ? null
          : ref.read(clinicRepositoryProvider).getAppointmentAvailability(
                doctor: selectedDoctor,
                service: selectedService,
                date: date,
              );
    });
  }

  @override
  Widget build(BuildContext context) {
    final availability = availabilityFuture;
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('1. Select service'),
          const SizedBox(height: 8),
          ref.watch(servicesProvider).when(
                data: (items) => DropdownButtonFormField<MedicalService>(
                  initialValue: service,
                  isExpanded: true,
                  items: items
                      .where((item) => item.id.isNotEmpty)
                      .map((item) => DropdownMenuItem<MedicalService>(
                            value: item,
                            child: Text(
                              '${item.name} · ${item.price.toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    service = value;
                    _refreshAvailability();
                  },
                  decoration: const InputDecoration(labelText: 'Service'),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Unable to load services: $error'),
              ),
          const SizedBox(height: 20),
          const Text('2. Select doctor'),
          const SizedBox(height: 8),
          ref.watch(doctorsProvider).when(
                data: (items) => DropdownButtonFormField<Doctor>(
                  initialValue: doctor,
                  isExpanded: true,
                  items: items
                      .where((item) => item.id.isNotEmpty)
                      .map((item) => DropdownMenuItem<Doctor>(
                            value: item,
                            child: Text(
                              '${item.name} · ${item.specialty}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    doctor = value;
                    _refreshAvailability();
                  },
                  decoration: const InputDecoration(labelText: 'Doctor'),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Unable to load doctors: $error'),
              ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('3. Choose date'),
            subtitle: Text(_datePart(date)),
            trailing: OutlinedButton(
              onPressed: () async {
                final today = DateUtils.dateOnly(DateTime.now());
                final selected = await showDatePicker(
                  context: context,
                  firstDate: today,
                  lastDate: today.add(const Duration(days: 90)),
                  initialDate: date.isBefore(today) ? today : date,
                );
                if (selected != null) {
                  date = selected;
                  _refreshAvailability();
                }
              },
              child: const Text('Choose'),
            ),
          ),
          const SizedBox(height: 8),
          const Text('4. Available appointment times'),
          const SizedBox(height: 4),
          Text(
            'Times are displayed in the clinic\'s local timezone. Availability is checked by the booking server.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (doctor == null || service == null)
            const Text('Select a service and doctor to see available times.')
          else if (availability == null)
            const Text('Select a date to check availability.')
          else
            FutureBuilder<List<AppointmentSlot>>(
              future: availability,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unable to check availability: ${snapshot.error}'),
                      TextButton(
                        onPressed: _refreshAvailability,
                        child: const Text('Try again'),
                      ),
                    ],
                  );
                }
                final slots = snapshot.data ?? const <AppointmentSlot>[];
                if (slots.isEmpty) {
                  return const Text(
                    'No appointments are available on this date. Please choose another date.',
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((slot) {
                    final selected = selectedSlot?.startTime == slot.startTime;
                    return ChoiceChip(
                      label: Text(slot.startTime),
                      selected: selected,
                      onSelected: (_) => setState(() => selectedSlot = slot),
                    );
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: doctor == null || service == null || selectedSlot == null || submitting
                ? null
                : () async {
                    setState(() => submitting = true);
                    try {
                      final appointment = await ref
                          .read(clinicRepositoryProvider)
                          .createAppointment(
                            doctor: doctor!,
                            service: service!,
                            date: date,
                            startTime: selectedSlot!.startTime,
                          );
                      ref.invalidate(appointmentsProvider);
                      if (!context.mounted) return;
                      await showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Appointment confirmed'),
                          content: Text(
                            '${appointment.number}\n'
                            '${appointment.doctor.name}\n'
                            '${appointment.service.name}\n'
                            '${appointment.startTime}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.go('/appointments'),
                              child: const Text('View appointments'),
                            ),
                          ],
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking failed: $error')),
                      );
                      // Another patient may have taken the slot after it was
                      // displayed. Refresh instead of allowing a stale retry.
                      _refreshAvailability();
                    } finally {
                      if (mounted) setState(() => submitting = false);
                    }
                  },
            child: submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm appointment'),
          ),
        ],
      ),
    );
  }
}
