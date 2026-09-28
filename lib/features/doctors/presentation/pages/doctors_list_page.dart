import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../app/router/route_names.dart';
import '../bloc/doctor_bloc.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctors_usecase.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DoctorBloc>().add(
      const LoadDoctorsEvent(GetDoctorsParams()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctors)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(
              AppDimensions.screenPaddingH,
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.translate('searchDoctor'),
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<DoctorBloc>().add(
                            const LoadDoctorsEvent(
                              GetDoctorsParams(),
                            ),
                          );
                        },
                      )
                    : null,
              ),
              onChanged: (q) {
                if (q.length >= 2) {
                  context
                      .read<DoctorBloc>()
                      .add(SearchDoctorsEvent(q));
                } else if (q.isEmpty) {
                  context.read<DoctorBloc>().add(
                    const LoadDoctorsEvent(GetDoctorsParams()),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                if (state is DoctorLoading) {
                  return const AppLoadingView(height: 300);
                }
                if (state is DoctorError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<DoctorBloc>().add(
                      const LoadDoctorsEvent(GetDoctorsParams()),
                    ),
                  );
                }
                if (state is DoctorEmpty) {
                  return AppEmptyView(
                    title: l10n.translate('noResults'),
                    icon: Icons.people_outline,
                  );
                }
                if (state is DoctorLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsetsDirectional.all(
                      AppDimensions.screenPaddingH,
                    ),
                    itemCount: state.doctors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(
                      height: AppDimensions.spaceM,
                    ),
                    itemBuilder: (context, i) => DoctorCard(
                      doctor: state.doctors[i],
                      onTap: () => context.push(
                        '${RouteNames.doctors}/${state.doctors[i].id}',
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;

  const DoctorCard({super.key, required this.doctor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppDimensions.avatarMd / 2,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person_outline,
                size: AppDimensions.iconLg,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    doctor.specialization,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                      Icon(
                        Icons.work_outline,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.experienceYears} ${l10n.translate("years")}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (doctor.isAvailableToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                    ),
                    child: Text(
                      l10n.translate('today'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  '${doctor.consultationFee.toInt()} SAR',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
