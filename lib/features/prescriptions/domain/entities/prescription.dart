import 'package:equatable/equatable.dart';

enum PrescriptionStatus { active, completed, cancelled, onHold }

class Prescription extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String appointmentId;
  final List<PrescribedMedication> medications;
  final String? instructions;
  final String? notes;
  final DateTime prescribedAt;
  final DateTime? validUntil;
  final PrescriptionStatus status;
  final bool isRefillable;
  final int refillsRemaining;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.medications,
    this.instructions,
    this.notes,
    required this.prescribedAt,
    this.validUntil,
    required this.status,
    this.isRefillable = false,
    this.refillsRemaining = 0,
  });

  bool get isActive => status == PrescriptionStatus.active;
  bool get isExpired =>
      validUntil != null && validUntil!.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, patientId, appointmentId];
}

class PrescribedMedication extends Equatable {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final bool isPRN;

  const PrescribedMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    this.isPRN = false,
  });

  @override
  List<Object?> get props => [name, dosage, frequency];
}
