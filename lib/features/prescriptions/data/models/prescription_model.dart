import '../../domain/entities/prescription.dart';

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    required super.doctorName,
    required super.appointmentId,
    required super.medications,
    super.instructions,
    super.notes,
    required super.prescribedAt,
    super.validUntil,
    required super.status,
    super.isRefillable,
    super.refillsRemaining,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> j) =>
      PrescriptionModel(
        id: j['id'] as String,
        patientId: j['patient_id'] as String,
        doctorId: j['doctor_id'] as String,
        doctorName: j['doctor_name'] as String? ?? '',
        appointmentId: j['appointment_id'] as String? ?? '',
        medications: (j['medications'] as List<dynamic>?)
                ?.map((m) => PrescribedMedication(
                      name: m['name'] as String,
                      dosage: m['dosage'] as String,
                      frequency: m['frequency'] as String,
                      duration: m['duration'] as String,
                      instructions: m['instructions'] as String?,
                      isPRN: m['is_prn'] as bool? ?? false,
                    ))
                .toList() ??
            [],
        instructions: j['instructions'] as String?,
        notes: j['notes'] as String?,
        prescribedAt:
            DateTime.parse(j['prescribed_at'] as String),
        validUntil: j['valid_until'] != null
            ? DateTime.parse(j['valid_until'] as String)
            : null,
        status: _parseStatus(j['status'] as String?),
        isRefillable: j['is_refillable'] as bool? ?? false,
        refillsRemaining: j['refills_remaining'] as int? ?? 0,
      );

  static PrescriptionStatus _parseStatus(String? s) {
    switch (s) {
      case 'completed':
        return PrescriptionStatus.completed;
      case 'cancelled':
        return PrescriptionStatus.cancelled;
      case 'on_hold':
        return PrescriptionStatus.onHold;
      default:
        return PrescriptionStatus.active;
    }
  }
}
