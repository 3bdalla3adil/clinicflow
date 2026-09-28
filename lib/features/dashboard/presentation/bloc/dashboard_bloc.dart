import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/usecases/get_upcoming_appointments_usecase.dart';
import '../../../../core/errors/failures.dart';

// ── Events ────────────────────────────────────────────────────
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends DashboardEvent {
  final String patientId;
  const LoadDashboardEvent(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class RefreshDashboardEvent extends DashboardEvent {
  final String patientId;
  const RefreshDashboardEvent(this.patientId);
}

// ── States ────────────────────────────────────────────────────
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Appointment> upcomingAppointments;
  final bool isRefreshing;
  const DashboardLoaded({
    required this.upcomingAppointments,
    this.isRefreshing = false,
  });
  @override
  List<Object?> get props => [upcomingAppointments, isRefreshing];
}

class DashboardEmpty extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  final bool isOffline;
  const DashboardError({required this.message, this.isOffline = false});
  @override
  List<Object?> get props => [message, isOffline];
}

// ── BLoC ──────────────────────────────────────────────────────
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetUpcomingAppointmentsUseCase getUpcomingAppointments;

  DashboardBloc({required this.getUpcomingAppointments})
      : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
    on<RefreshDashboardEvent>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await getUpcomingAppointments(event.patientId);
    result.fold(
      (failure) => emit(DashboardError(
        message: failure.message,
        isOffline: failure is NoInternetFailure,
      )),
      (appointments) => appointments.isEmpty
          ? emit(DashboardEmpty())
          : emit(DashboardLoaded(upcomingAppointments: appointments)),
    );
  }

  Future<void> _onRefresh(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is DashboardLoaded) {
      emit(DashboardLoaded(
        upcomingAppointments: current.upcomingAppointments,
        isRefreshing: true,
      ));
    }
    final result = await getUpcomingAppointments(event.patientId);
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (appointments) => appointments.isEmpty
          ? emit(DashboardEmpty())
          : emit(DashboardLoaded(upcomingAppointments: appointments)),
    );
  }
}
