import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/usecases/get_medical_records_usecase.dart';

abstract class EmrEvent extends Equatable {
  const EmrEvent();
  @override
  List<Object?> get props => [];
}

class LoadMedicalRecordsEvent extends EmrEvent {
  final String patientId;
  final RecordType? type;
  const LoadMedicalRecordsEvent(this.patientId, {this.type});
}

abstract class EmrState extends Equatable {
  const EmrState();
  @override
  List<Object?> get props => [];
}

class EmrInitial extends EmrState {}
class EmrLoading extends EmrState {}

class EmrLoaded extends EmrState {
  final List<MedicalRecord> records;
  const EmrLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class EmrEmpty extends EmrState {}

class EmrError extends EmrState {
  final String message;
  const EmrError(this.message);
}

class EmrBloc extends Bloc<EmrEvent, EmrState> {
  final GetMedicalRecordsUseCase getMedicalRecords;

  EmrBloc({required this.getMedicalRecords}) : super(EmrInitial()) {
    on<LoadMedicalRecordsEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMedicalRecordsEvent event,
    Emitter<EmrState> emit,
  ) async {
    emit(EmrLoading());
    final result =
        await getMedicalRecords(event.patientId, type: event.type);
    result.fold(
      (f) => emit(EmrError(f.message)),
      (records) => records.isEmpty
          ? emit(EmrEmpty())
          : emit(EmrLoaded(records)),
    );
  }
}
