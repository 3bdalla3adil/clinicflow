import 'package:flutter/material.dart';
import '../../app/localization/l10n.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final bool isOffline;
  final VoidCallback? onRetry;
  final double height;

  const AppErrorView({
    super.key,
    required this.message,
    this.isOffline = false,
    this.onRetry,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppDimensions.spaceXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isOffline
                      ? AppColors.warningContainer
                      : AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOffline
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  color: isOffline ? AppColors.warning : AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),
              Text(
                isOffline ? l10n.translate('noInternet') : l10n.error,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDimensions.spaceXL),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
