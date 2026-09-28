import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: l10n.translate('language'),
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.translate('language')),
                subtitle: Text(l10n.isArabic
                    ? l10n.translate('arabic')
                    : l10n.translate('english')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final newLocale = l10n.isArabic
                      ? const Locale('en')
                      : const Locale('ar');
                  context.read<AuthBloc>().add(
                    AuthChangeLocaleEvent(newLocale),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.translate('notifications'),
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l10n.translate('notifications')),
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Security',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint_outlined),
                title: Text(l10n.translate('biometricAuth') ?? 'Biometric'),
                value: false,
                onChanged: (_) {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.translate('privacyPolicy')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.translate('version') ?? 'Version'),
                trailing: const Text('1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppDimensions.screenPaddingH,
            end: AppDimensions.screenPaddingH,
            top: AppDimensions.spaceXXL,
            bottom: AppDimensions.spaceS,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        ...children,
        Divider(
          color: theme.colorScheme.outline.withOpacity(0.15),
          height: 1,
        ),
      ],
    );
  }
}
