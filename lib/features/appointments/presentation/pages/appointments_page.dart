import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../app/router/route_names.dart';
import '../bloc/appointment_bloc.dart';
import '../../../../features/dashboard/presentation/widgets/appointment_card.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AppointmentBloc>().add(
      const LoadUpcomingAppointmentsEvent('current_user_id'),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointments),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('upcomingAppointments')),
            Tab(text: l10n.translate('pastAppointments')),
          ],
        ),
      ),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoading) {
            return const AppLoadingView(height: 400);
          }
          if (state is AppointmentError) {
            return AppErrorView(
              message: state.message,
              isOffline: state.isOffline,
              onRetry: () => context.read<AppointmentBloc>().add(
                const LoadUpcomingAppointmentsEvent('current_user_id'),
              ),
            );
          }
          if (state is AppointmentEmpty) {
            return AppEmptyView(
              title: l10n.noAppointments,
              subtitle: l10n.noAppointmentsDesc,
              actionLabel: l10n.bookAppointment,
              onAction: () => context.push(RouteNames.bookAppointment),
              icon: Icons.calendar_today_outlined,
            );
          }
          if (state is AppointmentLoaded) {
            final upcoming = state.appointments
                .where((a) => a.isUpcoming)
                .toList();
            final past = state.appointments
                .where((a) => !a.isUpcoming)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(
                  appointments: upcoming,
                  emptyTitle: l10n.noAppointments,
                  emptySubtitle: l10n.noAppointmentsDesc,
                  l10n: l10n,
                ),
                _AppointmentList(
                  appointments: past,
                  emptyTitle: l10n.translate('pastAppointments'),
                  emptySubtitle: '',
                  l10n: l10n,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.bookAppointment),
        icon: const Icon(Icons.add),
        label: Text(l10n.bookAppointment),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List appointments;
  final String emptyTitle;
  final String emptySubtitle;
  final AppLocalizations l10n;

  const _AppointmentList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return AppEmptyView(
        title: emptyTitle,
        subtitle: emptySubtitle.isEmpty ? null : emptySubtitle,
        icon: Icons.calendar_today_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsetsDirectional.all(
        AppDimensions.screenPaddingH,
      ),
      itemCount: appointments.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceM),
      itemBuilder: (context, i) => AppointmentCard(
        appointment: appointments[i],
        onTap: () => context.push(
          '${RouteNames.appointments}/${appointments[i].id}',
        ),
      ),
    );
  }
}
