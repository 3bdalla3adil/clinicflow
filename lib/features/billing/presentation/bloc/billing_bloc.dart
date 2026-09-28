import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/get_invoices_usecase.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object?> get props => [];
}

class LoadInvoicesEvent extends BillingEvent {
  final String patientId;
  const LoadInvoicesEvent(this.patientId);
}

abstract class BillingState extends Equatable {
  const BillingState();
  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}
class BillingLoading extends BillingState {}

class BillingLoaded extends BillingState {
  final List<Invoice> invoices;
  const BillingLoaded(this.invoices);
  @override
  List<Object?> get props => [invoices];
}

class BillingEmpty extends BillingState {}

class BillingError extends BillingState {
  final String message;
  const BillingError(this.message);
}

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetInvoicesUseCase getInvoices;

  BillingBloc({required this.getInvoices}) : super(BillingInitial()) {
    on<LoadInvoicesEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadInvoicesEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    final result = await getInvoices(event.patientId);
    result.fold(
      (f) => emit(BillingError(f.message)),
      (invoices) => invoices.isEmpty
          ? emit(BillingEmpty())
          : emit(BillingLoaded(invoices)),
    );
  }
}
