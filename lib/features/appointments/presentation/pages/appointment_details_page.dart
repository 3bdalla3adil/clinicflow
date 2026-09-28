import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailsPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('viewDetails')),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Appointment #$appointmentId',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'Full details view — connect AppointmentBloc',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
