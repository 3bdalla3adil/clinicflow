import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
  rescheduled,
}

enum AppointmentType { inPerson, telehealth }

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String? doctorAvatarUrl;
  final String clinicId;
  final String clinicName;
  final DateTime scheduledAt;
  final Duration duration;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? notes;
  final String? symptoms;
  final double? consultationFee;
  final String? meetingUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    this.doctorAvatarUrl,
    required this.clinicId,
    required this.clinicName,
    required this.scheduledAt,
    this.duration = const Duration(minutes: 30),
    required this.status,
    required this.type,
    this.notes,
    this.symptoms,
    this.consultationFee,
    this.meetingUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUpcoming =>
      scheduledAt.isAfter(DateTime.now()) &&
      status != AppointmentStatus.cancelled;

  bool get isTelehealth => type == AppointmentType.telehealth;

  bool get canBeCancelled =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed;

  bool get canBeRescheduled => canBeCancelled;

  DateTime get endTime => scheduledAt.add(duration);

  @override
  List<Object?> get props => [
        id,
        patientId,
        doctorId,
        scheduledAt,
        status,
        type,
      ];
}
