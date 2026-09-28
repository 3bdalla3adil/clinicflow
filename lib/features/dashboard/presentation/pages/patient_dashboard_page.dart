import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../../app/router/route_names.dart';
import '../widgets/appointment_card.dart';
import '../bloc/dashboard_bloc.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() =>
      _PatientDashboardPageState();
}

class _PatientDashboardPageState
    extends State<PatientDashboardPage> {
  static const _patientId = 'current_user_id';

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(
      const LoadUpcomingAppointmentsEvent(_patientId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AppointmentBloc>().add(
              const RefreshAppointmentsEvent(_patientId),
            );
          },
          child: CustomScrollView(
            slivers: [
              // ── App Bar ───────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                titleSpacing: AppDimensions.screenPaddingH,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translateWithParams(
                        'welcomeUser',
                        {'name': 'أحمد'},
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.dashboard,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () =>
                        context.push(RouteNames.notifications),
                    tooltip: l10n.translate('notifications'),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppDimensions.spaceM,
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          context.push(RouteNames.patientProfile),
                      child: CircleAvatar(
                        radius: AppDimensions.avatarSm / 2,
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_outline,
                          size: AppDimensions.iconMd,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Offline Banner ─────────────────────────────────
              const SliverToBoxAdapter(
                child: OfflineBanner(),
              ),

              // ── Quick Stats ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppDimensions.screenPaddingH,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.spaceL),
                      _QuickStatsRow(),
                      const SizedBox(height: AppDimensions.spaceXXL),
                      _QuickActionsGrid(l10n: l10n),
                    ],
                  ),
                ),
              ),

              // ── Upcoming Appointments Header ───────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppDimensions.screenPaddingH,
                    end: AppDimensions.screenPaddingH,
                    top: AppDimensions.spaceXXL,
                    bottom: AppDimensions.spaceM,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.upcomingAppointments,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(RouteNames.appointments),
                        child: Text(l10n.viewAll),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Appointments List (BLoC) ───────────────────────
              BlocBuilder<AppointmentBloc, AppointmentState>(
                builder: (context, state) {
                  if (state is AppointmentLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: AppDimensions.screenPaddingH,
                        ),
                        child: ShimmerLoadingList(itemCount: 2),
                      ),
                    );
                  }

                  if (state is AppointmentError) {
                    return SliverToBoxAdapter(
                      child: AppErrorView(
                        message: state.message,
                        isOffline: state.isOffline,
                        onRetry: () => context
                            .read<AppointmentBloc>()
                            .add(
                          const LoadUpcomingAppointmentsEvent(
                            _patientId,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is AppointmentEmpty) {
                    return SliverToBoxAdapter(
                      child: AppEmptyView(
                        title: l10n.noAppointments,
                        subtitle: l10n.noAppointmentsDesc,
                        actionLabel: l10n.bookAppointment,
                        onAction: () =>
                            context.push(RouteNames.bookAppointment),
                        icon: Icons.calendar_today_outlined,
                      ),
                    );
                  }

                  if (state is AppointmentLoaded) {
                    final upcoming = state.appointments
                        .where((a) => a.isUpcoming)
                        .take(3)
                        .toList();

                    if (upcoming.isEmpty) {
                      return SliverToBoxAdapter(
                        child: AppEmptyView(
                          title: l10n.noAppointments,
                          subtitle: l10n.noAppointmentsDesc,
                          actionLabel: l10n.bookAppointment,
                          onAction: () => context
                              .push(RouteNames.bookAppointment),
                          icon: Icons.calendar_today_outlined,
                        ),
                      );
                    }

                    return SliverList.separated(
                      itemCount: upcoming.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(
                        height: AppDimensions.spaceM,
                      ),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppDimensions.screenPaddingH,
                        ),
                        child: AppointmentCard(
                          appointment: upcoming[index],
                          onTap: () => context.push(
                            '${RouteNames.appointments}/${upcoming[index].id}',
                          ),
                          onCancel: upcoming[index].canBeCancelled
                              ? () => _confirmCancel(
                                    context,
                                    upcoming[index],
                                  )
                              : null,
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(
                    child: SizedBox.shrink(),
                  );
                },
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space64),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.bookAppointment),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).bookAppointment),
      ),

      bottomNavigationBar: _BottomNav(),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    Appointment appointment,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('cancelAppointment')),
        content: Text(
          '${l10n.translate("confirm")} ${l10n.translate("cancelAppointment")}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelled,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppointmentBloc>().add(
        CancelAppointmentEvent(appointment.id),
      );
    }
  }
}

class _QuickStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'مواعيد هذا الشهر',
            value: '3',
            icon: Icons.calendar_month_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: _StatCard(
            label: 'وصفات فعّالة',
            value: '2',
            icon: Icons.medication_outlined,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: _StatCard(
            label: 'فواتير معلّقة',
            value: '1',
            icon: Icons.receipt_outlined,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconLg),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final AppLocalizations l10n;
  const _QuickActionsGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.calendar_today_outlined,
        label: l10n.bookAppointment,
        color: AppColors.primary,
        onTap: () => context.push(RouteNames.bookAppointment),
      ),
      _QuickAction(
        icon: Icons.people_outline,
        label: l10n.doctors,
        color: AppColors.secondary,
        onTap: () => context.push(RouteNames.doctors),
      ),
      _QuickAction(
        icon: Icons.folder_outlined,
        label: l10n.medicalRecords,
        color: AppColors.accent,
        onTap: () => context.push(RouteNames.emrRecords),
      ),
      _QuickAction(
        icon: Icons.medication_outlined,
        label: l10n.prescriptions,
        color: AppColors.phiBadge,
        onTap: () => context.push(RouteNames.prescriptions),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimensions.spaceM,
      mainAxisSpacing: AppDimensions.spaceM,
      childAspectRatio: 0.85,
      children: actions
          .map(
            (a) => GestureDetector(
              onTap: a.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: a.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Icon(
                      a.icon,
                      color: a.color,
                      size: AppDimensions.iconLg,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.dashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today),
          label: l10n.appointments,
        ),
        NavigationDestination(
          icon: const Icon(Icons.folder_outlined),
          selectedIcon: const Icon(Icons.folder),
          label: l10n.medicalRecords,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 1:
            context.push(RouteNames.appointments);
            break;
          case 2:
            context.push(RouteNames.emrRecords);
            break;
          case 3:
            context.push(RouteNames.patientProfile);
            break;
        }
      },
    );
  }
}
