import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/appointment_bloc.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() =>
      _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  int _step = 0;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeSlot? _selectedSlot;
  AppointmentType _selectedType = AppointmentType.inPerson;
  final _symptomsCtrl = TextEditingController();

  // Mock slots — replace with BLoC-driven data
  final List<TimeSlot> _mockSlots = List.generate(
    8,
    (i) => TimeSlot(
      startTime: DateTime.now().copyWith(
        hour: 8 + i,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      endTime: DateTime.now().copyWith(
        hour: 8 + i + 1,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      isAvailable: i % 3 != 0,
    ),
  );

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentBooked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('appointmentConfirmed')),
              backgroundColor: AppColors.statusConfirmed,
            ),
          );
          context.pop();
        }
        if (state is AppointmentBookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookAppointment),
          leading: BackButton(onPressed: () => context.pop()),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              backgroundColor:
                  theme.colorScheme.surfaceVariant,
            ),
          ),
        ),
        body: IndexedStack(
          index: _step,
          children: [
            _StepDateAndType(
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              selectedType: _selectedType,
              slots: _mockSlots,
              selectedSlot: _selectedSlot,
              onDaySelected: (day, focused) => setState(() {
                _selectedDay = day;
                _focusedDay = focused;
                _selectedSlot = null;
              }),
              onTypeChanged: (t) =>
                  setState(() => _selectedType = t),
              onSlotSelected: (s) =>
                  setState(() => _selectedSlot = s),
              l10n: l10n,
            ),
            _StepSymptoms(
              controller: _symptomsCtrl,
              l10n: l10n,
            ),
            _StepConfirmation(
              selectedDay: _selectedDay,
              selectedSlot: _selectedSlot,
              selectedType: _selectedType,
              symptoms: _symptomsCtrl.text,
              l10n: l10n,
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsetsDirectional.all(
            AppDimensions.screenPaddingH,
          ),
          child: BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              return Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: AppButton(
                        label: l10n.translate('back'),
                        variant: AppButtonVariant.outlined,
                        onPressed: () =>
                            setState(() => _step--),
                      ),
                    ),
                    const SizedBox(
                      width: AppDimensions.spaceM,
                    ),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _step < 2
                          ? l10n.translate('next')
                          : l10n.bookAppointment,
                      isLoading: state is AppointmentBooking,
                      onPressed: _canProceed() ? _proceed : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_step == 0) return _selectedSlot != null;
    return true;
  }

  void _proceed() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.read<AppointmentBloc>().add(
        BookAppointmentEvent(
          BookingParams(
            patientId: 'current_user_id',
            doctorId: 'doctor_id',
            clinicId: 'clinic_id',
            scheduledAt: DateTime(
              _selectedDay.year,
              _selectedDay.month,
              _selectedDay.day,
              _selectedSlot!.startTime.hour,
              _selectedSlot!.startTime.minute,
            ),
            type: _selectedType,
            symptoms: _symptomsCtrl.text.isEmpty
                ? null
                : _symptomsCtrl.text,
          ),
        ),
      );
    }
  }
}

class _StepDateAndType extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final AppointmentType selectedType;
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(AppointmentType) onTypeChanged;
  final void Function(TimeSlot) onSlotSelected;
  final AppLocalizations l10n;

  const _StepDateAndType({
    required this.selectedDay,
    required this.focusedDay,
    required this.selectedType,
    required this.slots,
    required this.selectedSlot,
    required this.onDaySelected,
    required this.onTypeChanged,
    required this.onSlotSelected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(
        AppDimensions.screenPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('selectDate'),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, selectedDay),
            onDaySelected: onDaySelected,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXXL),

          // Type selection
          Text(
            l10n.translate('appointmentType'),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  label: l10n.translate('inPerson'),
                  icon: Icons.person_outline,
                  isSelected:
                      selectedType == AppointmentType.inPerson,
                  onTap: () =>
                      onTypeChanged(AppointmentType.inPerson),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: _TypeChip(
                  label: l10n.translate('telehealth'),
                  icon: Icons.video_call_outlined,
                  isSelected:
                      selectedType == AppointmentType.telehealth,
                  onTap: () =>
                      onTypeChanged(AppointmentType.telehealth),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceXXL),

          // Time slots
          Text(
            l10n.translate('availableSlots'),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Wrap(
            spacing: AppDimensions.spaceM,
            runSpacing: AppDimensions.spaceM,
            children: slots.map((slot) {
              final isSelected = selectedSlot == slot;
              final timeStr =
                  '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}';
              return GestureDetector(
                onTap: slot.isAvailable
                    ? () => onSlotSelected(slot)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceL,
                    vertical: AppDimensions.spaceM,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : slot.isAvailable
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusM,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    timeStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : slot.isAvailable
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(width: AppDimensions.spaceS),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepSymptoms extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;

  const _StepSymptoms({
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(
        AppDimensions.screenPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('symptoms'),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          TextFormField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l10n.translate('symptoms'),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
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
        ],
      ),
    );
  }
}

class _StepConfirmation extends StatelessWidget {
  final DateTime selectedDay;
  final TimeSlot? selectedSlot;
  final AppointmentType selectedType;
  final String symptoms;
  final AppLocalizations l10n;

  const _StepConfirmation({
    required this.selectedDay,
    required this.selectedSlot,
    required this.selectedType,
    required this.symptoms,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(
        AppDimensions.screenPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('confirm'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.spaceXXL),
          _ConfirmRow(
            label: l10n.translate('date'),
            value:
                '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}',
          ),
          if (selectedSlot != null)
            _ConfirmRow(
              label: l10n.translate('time'),
              value:
                  '${selectedSlot!.startTime.hour.toString().padLeft(2, '0')}:${selectedSlot!.startTime.minute.toString().padLeft(2, '0')}',
            ),
          _ConfirmRow(
            label: l10n.translate('appointmentType'),
            value: selectedType == AppointmentType.inPerson
                ? l10n.translate('inPerson')
                : l10n.translate('telehealth'),
          ),
          if (symptoms.isNotEmpty)
            _ConfirmRow(
              label: l10n.translate('symptoms'),
              value: symptoms,
            ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
