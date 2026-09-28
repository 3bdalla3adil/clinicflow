import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/get_doctor_schedule_usecase.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();
  @override
  List<Object?> get props => [];
}

class LoadDoctorsEvent extends DoctorEvent {
  final GetDoctorsParams params;
  const LoadDoctorsEvent(this.params);
}

class SearchDoctorsEvent extends DoctorEvent {
  final String query;
  const SearchDoctorsEvent(this.query);
}

class LoadDoctorScheduleEvent extends DoctorEvent {
  final String doctorId;
  final DateTime date;
  const LoadDoctorScheduleEvent(this.doctorId, this.date);
}

abstract class DoctorState extends Equatable {
  const DoctorState();
  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}
class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<Doctor> doctors;
  const DoctorLoaded(this.doctors);
  @override
  List<Object?> get props => [doctors];
}

class DoctorEmpty extends DoctorState {}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError(this.message);
}

class DoctorScheduleLoaded extends DoctorState {
  final List<TimeSlot> slots;
  const DoctorScheduleLoaded(this.slots);
}

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final GetDoctorsUseCase getDoctors;
  final GetDoctorScheduleUseCase getDoctorSchedule;

  DoctorBloc({
    required this.getDoctors,
    required this.getDoctorSchedule,
  }) : super(DoctorInitial()) {
    on<LoadDoctorsEvent>(_onLoad);
    on<SearchDoctorsEvent>(_onSearch);
    on<LoadDoctorScheduleEvent>(_onSchedule);
  }

  Future<void> _onLoad(
    LoadDoctorsEvent event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());
    final result = await getDoctors(event.params);
    result.fold(
      (f) => emit(DoctorError(f.message)),
      (doctors) => doctors.isEmpty
          ? emit(DoctorEmpty())
          : emit(DoctorLoaded(doctors)),
    );
  }

  Future<void> _onSearch(
    SearchDoctorsEvent event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());
    final result = await getDoctors(
      GetDoctorsParams(query: event.query),
    );
    result.fold(
      (f) => emit(DoctorError(f.message)),
      (doctors) => doctors.isEmpty
          ? emit(DoctorEmpty())
          : emit(DoctorLoaded(doctors)),
    );
  }

  Future<void> _onSchedule(
    LoadDoctorScheduleEvent event,
    Emitter<DoctorState> emit,
  ) async {
    final result = await getDoctorSchedule(
      event.doctorId,
      event.date,
    );
    result.fold(
      (f) => emit(DoctorError(f.message)),
      (slots) => emit(DoctorScheduleLoaded(slots)),
    );
  }
}
