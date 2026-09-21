import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../shared/widgets/status_badge.dart';

class AppointmentsPage extends ConsumerWidget {
  const AppointmentsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My appointments')),
      body: ref.watch(appointmentsProvider).when(
        data: (xs) => xs.isEmpty ? const Center(child: Text('No appointments yet.')) : ListView.separated(
          padding: const EdgeInsets.all(16), itemCount: xs.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) { final a = xs[i]; return Card(child: ListTile(title: Text(a.service.name), subtitle: Text('\${a.doctor.name}\n\${a.number} · \${a.startTime}'), isThreeLine: true, trailing: StatusBadge(a.status))); },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load appointments: $e')),
      ),
    );
  }
}