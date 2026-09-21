enum UserRole { admin, reception, doctor, accountant, patient }

enum AppointmentStatus {
  scheduled,
  checkedIn,
  inConsultation,
  completed,
  cancelled,
  noShow
}

class AppUser {
  const AppUser(
      {required this.id,
      required this.email,
      required this.name,
      required this.role,
      required this.clinicId});
  final String id, email, name, clinicId;
  final UserRole role;
}

class Doctor {
  const Doctor(
      {required this.id,
      required this.name,
      required this.specialty,
      required this.durationMinutes});
  final String id, name, specialty;
  final int durationMinutes;
}

class MedicalService {
  const MedicalService(
      {required this.id, required this.name, required this.price});
  final String id, name;
  final double price;
}

class Appointment {
  const Appointment(
      {required this.id,
      required this.number,
      required this.doctor,
      required this.service,
      required this.date,
      required this.startTime,
      required this.status});
  final String id, number, startTime;
  final Doctor doctor;
  final MedicalService service;
  final DateTime date;
  final AppointmentStatus status;
}

String statusLabel(AppointmentStatus s) => switch (s) {
      AppointmentStatus.scheduled => 'Scheduled',
      AppointmentStatus.checkedIn => 'Checked in',
      AppointmentStatus.inConsultation => 'In consultation',
      AppointmentStatus.completed => 'Completed',
      AppointmentStatus.cancelled => 'Cancelled',
      AppointmentStatus.noShow => 'No show'
    };
