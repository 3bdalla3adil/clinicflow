import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
import '../bloc/prescription_bloc.dart';
import '../../domain/entities/prescription.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PrescriptionBloc>()
        .add(const LoadPrescriptionsEvent('current_user_id'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.prescriptions)),
      body: BlocBuilder<PrescriptionBloc, PrescriptionState>(
        builder: (context, state) {
          if (state is PrescriptionLoading) {
            return const AppLoadingView(height: 300);
          }
          if (state is PrescriptionError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<PrescriptionBloc>().add(
                const LoadPrescriptionsEvent('current_user_id'),
              ),
            );
          }
          if (state is PrescriptionEmpty) {
            return AppEmptyView(
              title: l10n.prescriptions,
              subtitle: 'No prescriptions found.',
              icon: Icons.medication_outlined,
            );
          }
          if (state is PrescriptionLoaded) {
            return ListView.separated(
              padding: const EdgeInsetsDirectional.all(
                AppDimensions.screenPaddingH,
              ),
              itemCount: state.prescriptions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceM),
              itemBuilder: (context, i) => PrescriptionCard(
                prescription: state.prescriptions[i],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  const PrescriptionCard({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isActive = prescription.isActive;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isActive
              ? AppColors.statusConfirmed.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prescription.doctorName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.successContainer
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                ),
                child: Text(
                  isActive
                      ? l10n.translate('paid')
                      : l10n.translate('status'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppColors.success
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            DateFormat('d MMM yyyy', l10n.locale.languageCode)
                .format(prescription.prescribedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          ...prescription.medications.take(3).map(
            (med) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spaceS,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medication_outlined,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    med.name,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    '• ${med.dosage} • ${med.frequency}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (prescription.medications.length > 3)
            Text(
              '+${prescription.medications.length - 3} more',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
