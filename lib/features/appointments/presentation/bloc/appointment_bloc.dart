import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/usecases/get_upcoming_appointments_usecase.dart';
import '../../domain/usecases/book_appointment_usecase.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';
import '../../domain/usecases/reschedule_appointment_usecase.dart';
import '../../../../core/errors/failures.dart';

// ── Events ─────────────────────────────────────────────────────
abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

class LoadUpcomingAppointmentsEvent extends AppointmentEvent {
  final String patientId;
  const LoadUpcomingAppointmentsEvent(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class BookAppointmentEvent extends AppointmentEvent {
  final BookingParams params;
  const BookAppointmentEvent(this.params);
}

class CancelAppointmentEvent extends AppointmentEvent {
  final String appointmentId;
  final String? reason;
  const CancelAppointmentEvent(this.appointmentId, {this.reason});
  @override
  List<Object?> get props => [appointmentId];
}

class RescheduleAppointmentEvent extends AppointmentEvent {
  final String appointmentId;
  final DateTime newDateTime;
  const RescheduleAppointmentEvent(this.appointmentId, this.newDateTime);
}

class RefreshAppointmentsEvent extends AppointmentEvent {
  final String patientId;
  const RefreshAppointmentsEvent(this.patientId);
}

// ── States ─────────────────────────────────────────────────────
abstract class AppointmentState extends Equatable {
  const AppointmentState();
  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<Appointment> appointments;
  final bool isRefreshing;
  const AppointmentLoaded({
    required this.appointments,
    this.isRefreshing = false,
  });
  @override
  List<Object?> get props => [appointments, isRefreshing];
}

class AppointmentEmpty extends AppointmentState {}

class AppointmentError extends AppointmentState {
  final String message;
  final bool isOffline;
  const AppointmentError({
    required this.message,
    this.isOffline = false,
  });
  @override
  List<Object?> get props => [message, isOffline];
}

class AppointmentBooking extends AppointmentState {}

class AppointmentBooked extends AppointmentState {
  final Appointment appointment;
  const AppointmentBooked(this.appointment);
  @override
  List<Object?> get props => [appointment];
}

class AppointmentCancelling extends AppointmentState {}

class AppointmentCancelled extends AppointmentState {
  final String appointmentId;
  const AppointmentCancelled(this.appointmentId);
}

class AppointmentBookingError extends AppointmentState {
  final String message;
  const AppointmentBookingError(this.message);
}

// ── BLoC ───────────────────────────────────────────────────────
class AppointmentBloc
    extends Bloc<AppointmentEvent, AppointmentState> {
  final GetUpcomingAppointmentsUseCase getUpcoming;
  final BookAppointmentUseCase bookAppointment;
  final CancelAppointmentUseCase cancelAppointment;
  final RescheduleAppointmentUseCase rescheduleAppointment;

  AppointmentBloc({
    required this.getUpcoming,
    required this.bookAppointment,
    required this.cancelAppointment,
    required this.rescheduleAppointment,
  }) : super(AppointmentInitial()) {
    on<LoadUpcomingAppointmentsEvent>(_onLoadUpcoming);
    on<BookAppointmentEvent>(_onBook);
    on<CancelAppointmentEvent>(_onCancel);
    on<RescheduleAppointmentEvent>(_onReschedule);
    on<RefreshAppointmentsEvent>(_onRefresh);
  }

  Future<void> _onLoadUpcoming(
    LoadUpcomingAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    final result = await getUpcoming(event.patientId);
    result.fold(
      (failure) => emit(AppointmentError(
        message: failure.message,
        isOffline: failure is NoInternetFailure,
      )),
      (appointments) => appointments.isEmpty
          ? emit(AppointmentEmpty())
          : emit(AppointmentLoaded(appointments: appointments)),
    );
  }

  Future<void> _onBook(
    BookAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentBooking());
    final result = await bookAppointment(event.params);
    result.fold(
      (failure) => emit(AppointmentBookingError(failure.message)),
      (appointment) => emit(AppointmentBooked(appointment)),
    );
  }

  Future<void> _onCancel(
    CancelAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentCancelling());
    final result = await cancelAppointment(
      event.appointmentId,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(AppointmentError(message: failure.message)),
      (_) => emit(AppointmentCancelled(event.appointmentId)),
    );
  }

  Future<void> _onRefresh(
    RefreshAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is AppointmentLoaded) {
      emit(AppointmentLoaded(
        appointments: current.appointments,
        isRefreshing: true,
      ));
    }
    final result = await getUpcoming(event.patientId);
    result.fold(
      (failure) =>
          emit(AppointmentError(message: failure.message)),
      (appointments) => appointments.isEmpty
          ? emit(AppointmentEmpty())
          : emit(AppointmentLoaded(appointments: appointments)),
    );
  }

  Future<void> _onReschedule(
    RescheduleAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final result = await rescheduleAppointment(
      event.appointmentId,
      event.newDateTime,
    );
    result.fold(
      (failure) =>
          emit(AppointmentError(message: failure.message)),
      (appointment) => emit(AppointmentBooked(appointment)),
    );
  }
}
