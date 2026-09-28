import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/usecases/get_prescriptions_usecase.dart';

abstract class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();
  @override
  List<Object?> get props => [];
}

class LoadPrescriptionsEvent extends PrescriptionEvent {
  final String patientId;
  const LoadPrescriptionsEvent(this.patientId);
}

abstract class PrescriptionState extends Equatable {
  const PrescriptionState();
  @override
  List<Object?> get props => [];
}

class PrescriptionInitial extends PrescriptionState {}
class PrescriptionLoading extends PrescriptionState {}

class PrescriptionLoaded extends PrescriptionState {
  final List<Prescription> prescriptions;
  const PrescriptionLoaded(this.prescriptions);
  @override
  List<Object?> get props => [prescriptions];
}

class PrescriptionEmpty extends PrescriptionState {}

class PrescriptionError extends PrescriptionState {
  final String message;
  const PrescriptionError(this.message);
}

class PrescriptionBloc
    extends Bloc<PrescriptionEvent, PrescriptionState> {
  final GetPrescriptionsUseCase getPrescriptions;

  PrescriptionBloc({required this.getPrescriptions})
      : super(PrescriptionInitial()) {
    on<LoadPrescriptionsEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPrescriptionsEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    final result = await getPrescriptions(event.patientId);
    result.fold(
      (f) => emit(PrescriptionError(f.message)),
      (prescriptions) => prescriptions.isEmpty
          ? emit(PrescriptionEmpty())
          : emit(PrescriptionLoaded(prescriptions)),
    );
  }
}
