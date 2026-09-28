import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.patientId,
    super.appointmentId,
    required super.invoiceNumber,
    required super.lineItems,
    required super.subtotal,
    super.taxAmount,
    super.discountAmount,
    required super.totalAmount,
    super.paidAmount,
    required super.status,
    super.paymentMethod,
    required super.issuedAt,
    super.dueDate,
    super.paidAt,
    super.notes,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> j) =>
      InvoiceModel(
        id: j['id'] as String,
        patientId: j['patient_id'] as String,
        appointmentId: j['appointment_id'] as String?,
        invoiceNumber: j['invoice_number'] as String,
        lineItems: (j['line_items'] as List<dynamic>?)
                ?.map((e) {
                  final item = e as Map<String, dynamic>;
                  return InvoiceLineItem(
                    description: item['description'] as String,
                    quantity: item['quantity'] as int? ?? 1,
                    unitPrice:
                        (item['unit_price'] as num?)?.toDouble() ??
                            0.0,
                    totalPrice:
                        (item['total_price'] as num?)?.toDouble() ??
                            0.0,
                    serviceCode: item['service_code'] as String?,
                  );
                })
                .toList() ??
            [],
        subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (j['tax_amount'] as num?)?.toDouble() ?? 0.0,
        discountAmount:
            (j['discount_amount'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (j['total_amount'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (j['paid_amount'] as num?)?.toDouble() ?? 0.0,
        status: _parseStatus(j['status'] as String?),
        issuedAt: DateTime.parse(j['issued_at'] as String),
        dueDate: j['due_date'] != null
            ? DateTime.parse(j['due_date'] as String)
            : null,
        paidAt: j['paid_at'] != null
            ? DateTime.parse(j['paid_at'] as String)
            : null,
      );

  static InvoiceStatus _parseStatus(String? s) {
    switch (s) {
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      case 'refunded':
        return InvoiceStatus.refunded;
      case 'draft':
        return InvoiceStatus.draft;
      default:
        return InvoiceStatus.pending;
    }
  }
}
