import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    required super.doctorName,
    required super.doctorSpecialization,
    super.doctorAvatarUrl,
    required super.clinicId,
    required super.clinicName,
    required super.scheduledAt,
    super.duration,
    required super.status,
    required super.type,
    super.notes,
    super.symptoms,
    super.consultationFee,
    super.meetingUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> j) =>
      AppointmentModel(
        id: j['id'] as String,
        patientId: j['patient_id'] as String,
        doctorId: j['doctor_id'] as String,
        doctorName: j['doctor_name'] as String? ?? '',
        doctorSpecialization:
            j['doctor_specialization'] as String? ?? '',
        doctorAvatarUrl: j['doctor_avatar_url'] as String?,
        clinicId: j['clinic_id'] as String? ?? '',
        clinicName: j['clinic_name'] as String? ?? '',
        scheduledAt: DateTime.parse(j['scheduled_at'] as String),
        duration:
            Duration(minutes: (j['duration_minutes'] as int?) ?? 30),
        status: _parseStatus(j['status'] as String?),
        type: (j['type'] as String?) == 'telehealth'
            ? AppointmentType.telehealth
            : AppointmentType.inPerson,
        notes: j['notes'] as String?,
        symptoms: j['symptoms'] as String?,
        consultationFee:
            (j['consultation_fee'] as num?)?.toDouble(),
        meetingUrl: j['meeting_url'] as String?,
        createdAt: DateTime.parse(
          j['created_at'] as String? ??
              DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          j['updated_at'] as String? ??
              DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': status.name,
        'type': type.name,
      };

  static AppointmentStatus _parseStatus(String? s) {
    switch (s) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      default:
        return AppointmentStatus.pending;
    }
  }
}
