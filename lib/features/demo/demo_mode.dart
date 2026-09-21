import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class DemoBanner extends ConsumerWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(demoModeProvider)) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.orange.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Demo Mode — data is not saved',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(clinicRepositoryProvider).signOut();
                  ref.read(demoModeProvider.notifier).state = false;
                  ref.invalidate(currentUserProvider);
                  ref.invalidate(appointmentsProvider);
                  if (!context.mounted) return;
                  ref.read(routerRefreshProvider);
                  // The app uses go_router; this keeps the banner action
                  // independent of route implementation details.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('EXIT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder provider used to make the banner depend only on app state.
final routerRefreshProvider = Provider<void>((_) {});
