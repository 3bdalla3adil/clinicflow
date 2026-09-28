import 'package:equatable/equatable.dart';

enum InvoiceStatus {
  draft,
  pending,
  paid,
  overdue,
  cancelled,
  refunded,
}

enum PaymentMethod { cash, card, insurance, bankTransfer, online }

class Invoice extends Equatable {
  final String id;
  final String patientId;
  final String? appointmentId;
  final String invoiceNumber;
  final List<InvoiceLineItem> lineItems;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final InvoiceStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime issuedAt;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? notes;

  const Invoice({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.invoiceNumber,
    required this.lineItems,
    required this.subtotal,
    this.taxAmount = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.status,
    this.paymentMethod,
    required this.issuedAt,
    this.dueDate,
    this.paidAt,
    this.notes,
  });

  double get balanceDue => totalAmount - paidAmount;
  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status == InvoiceStatus.pending;

  @override
  List<Object?> get props => [id, patientId, invoiceNumber, status];
}

class InvoiceLineItem extends Equatable {
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? serviceCode;

  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.serviceCode,
  });

  @override
  List<Object?> get props => [description, quantity, unitPrice];
}
