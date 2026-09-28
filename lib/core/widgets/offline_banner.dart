import 'package:flutter/material.dart';
import '../../app/localization/l10n.dart';
import '../../app/theme/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  const OfflineBanner({super.key, this.isOffline = false});

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AppColors.warningContainer,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).translate('offlineMode'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
