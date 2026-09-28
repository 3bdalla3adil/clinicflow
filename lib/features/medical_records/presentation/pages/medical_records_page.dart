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
import '../bloc/emr_bloc.dart';
import '../../domain/entities/medical_record.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() =>
      _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<EmrBloc>()
        .add(const LoadMedicalRecordsEvent('current_user_id'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalRecords)),
      body: BlocBuilder<EmrBloc, EmrState>(
        builder: (context, state) {
          if (state is EmrLoading) {
            return const AppLoadingView(height: 300);
          }
          if (state is EmrError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<EmrBloc>().add(
                const LoadMedicalRecordsEvent('current_user_id'),
              ),
            );
          }
          if (state is EmrEmpty) {
            return AppEmptyView(
              title: l10n.medicalRecords,
              subtitle: 'No medical records found.',
              icon: Icons.folder_outlined,
            );
          }
          if (state is EmrLoaded) {
            return ListView.separated(
              padding: const EdgeInsetsDirectional.all(
                AppDimensions.screenPaddingH,
              ),
              itemCount: state.records.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceM),
              itemBuilder: (context, i) =>
                  MedicalRecordCard(record: state.records[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  const MedicalRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _typeColor(record.type).withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              _typeIcon(record.type),
              color: _typeColor(record.type),
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (record.doctorName != null)
                  Text(
                    record.doctorName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  DateFormat('d MMM yyyy', l10n.locale.languageCode)
                      .format(record.recordDate),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (record.isConfidential)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppDimensions.spaceS,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.phiContainer,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusRound,
                  ),
                ),
                child: const Text(
                  'PHI',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.phiBadge,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Color _typeColor(RecordType t) {
    switch (t) {
      case RecordType.labResult:
        return AppColors.secondary;
      case RecordType.imaging:
        return AppColors.info;
      case RecordType.vaccination:
        return AppColors.accent;
      case RecordType.allergy:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(RecordType t) {
    switch (t) {
      case RecordType.labResult:
        return Icons.science_outlined;
      case RecordType.imaging:
        return Icons.image_outlined;
      case RecordType.vaccination:
        return Icons.vaccines_outlined;
      case RecordType.allergy:
        return Icons.warning_outlined;
      case RecordType.vitalSigns:
        return Icons.monitor_heart_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}
