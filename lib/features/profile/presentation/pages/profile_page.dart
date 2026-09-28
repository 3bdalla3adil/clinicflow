import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(
          AppDimensions.screenPaddingH,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spaceXXL),
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
              'Patient Name',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'patient@example.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXXXL),

            // Profile items
            _ProfileItem(
              icon: Icons.person_outline,
              label: l10n.translate('fullName'),
              value: 'Patient Name',
            ),
            _ProfileItem(
              icon: Icons.email_outlined,
              label: l10n.email,
              value: 'patient@example.com',
            ),
            _ProfileItem(
              icon: Icons.phone_outlined,
              label: l10n.translate('phone'),
              value: '+966 5x xxx xxxx',
            ),
            _ProfileItem(
              icon: Icons.wc_outlined,
              label: l10n.translate('gender'),
              value: l10n.translate('male'),
            ),
            _ProfileItem(
              icon: Icons.opacity_outlined,
              label: l10n.translate('bloodType'),
              value: 'O+',
            ),
            const SizedBox(height: AppDimensions.spaceXXL),

            // PHI notice
            Container(
              padding: const EdgeInsetsDirectional.all(
                AppDimensions.spaceM,
              ),
              decoration: BoxDecoration(
                color: AppColors.phiContainer,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_outlined,
                    color: AppColors.phiBadge,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  Expanded(
                    child: Text(
                      l10n.phiNotice,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.phiBadge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXXL),

            // Logout
            AppButton(
              label: l10n.translate('logout'),
              variant: AppButtonVariant.destructive,
              icon: Icons.logout,
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutEvent());
                context.go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceL),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconMd,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
