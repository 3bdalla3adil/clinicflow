import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';

class DoctorProfilePage extends StatelessWidget {
  final String doctorId;
  const DoctorProfilePage({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('doctor')),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(
                AppDimensions.spaceXXXL,
              ),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: AppDimensions.avatarXL / 2,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline,
                      size: AppDimensions.iconXL,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceL),
                  Text(
                    'Dr. Doctor #$doctorId',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    l10n.translate('specialization'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: Color(0xFFF59E0B),
                      ),
                      const Text('4.8'),
                      const SizedBox(width: AppDimensions.spaceXXL),
                      Icon(
                        Icons.work_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const Text('10 years'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.all(
                AppDimensions.screenPaddingH,
              ),
              child: AppButton(
                label: l10n.translate('bookNow'),
                icon: Icons.calendar_today_outlined,
                onPressed: () =>
                    context.push(RouteNames.bookAppointment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
