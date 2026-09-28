import 'package:flutter/material.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../appointments/domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final statusColor = _statusColor(appointment.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppDimensions.spaceL),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Doctor info + status
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: AppDimensions.avatarSm / 2,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: appointment.doctorAvatarUrl != null
                      ? null
                      : Icon(
                          Icons.person_outline,
                          size: AppDimensions.iconMd,
                          color: theme.colorScheme.primary,
                        ),
                ),
                const SizedBox(width: AppDimensions.spaceM),

                // Doctor name & specialization
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appointment.doctorSpecialization,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceM,
                    vertical: AppDimensions.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusRound,
                    ),
                  ),
                  child: Text(
                    _statusLabel(appointment.status, l10n),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceM),
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.15),
              height: 1,
            ),
            const SizedBox(height: AppDimensions.spaceM),

            // Date, time, clinic
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(appointment.scheduledAt, l10n),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                _InfoChip(
                  icon: Icons.access_time_outlined,
                  label: DateFormat('HH:mm').format(
                    appointment.scheduledAt,
                  ),
                ),
                if (appointment.isTelehealth) ...[
                  const SizedBox(width: AppDimensions.spaceM),
                  _InfoChip(
                    icon: Icons.video_call_outlined,
                    label: l10n.translate('telehealth'),
                    color: AppColors.secondary,
                  ),
                ],
              ],
            ),

            // Clinic name
            const SizedBox(height: AppDimensions.spaceS),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: AppDimensions.iconSm,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.spaceXS),
                Text(
                  appointment.clinicName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Cancel button
            if (onCancel != null && appointment.canBeCancelled) ...[
              const SizedBox(height: AppDimensions.spaceM),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: AppDimensions.iconSm,
                    color: AppColors.statusCancelled,
                  ),
                  label: Text(
                    l10n.translate('cancelAppointment'),
                    style: const TextStyle(
                      color: AppColors.statusCancelled,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return l10n.translate('today');
    if (date == today.add(const Duration(days: 1))) {
      return l10n.translate('tomorrow');
    }
    return DateFormat('d MMM', l10n.locale.languageCode).format(dt);
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed;
      case AppointmentStatus.pending:
        return AppColors.statusPending;
      case AppointmentStatus.cancelled:
        return AppColors.statusCancelled;
      case AppointmentStatus.completed:
        return AppColors.statusCompleted;
      default:
        return AppColors.statusPending;
    }
  }

  String _statusLabel(
    AppointmentStatus status,
    AppLocalizations l10n,
  ) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return l10n.translate('appointmentConfirmed');
      case AppointmentStatus.pending:
        return l10n.translate('appointmentPending');
      case AppointmentStatus.cancelled:
        return l10n.translate('appointmentCancelled');
      case AppointmentStatus.completed:
        return l10n.translate('appointmentCompleted');
      default:
        return l10n.translate('appointmentPending');
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: c),
        const SizedBox(width: AppDimensions.spaceXS),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: c),
        ),
      ],
    );
  }
}
