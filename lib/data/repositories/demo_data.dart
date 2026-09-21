import '../models/models.dart';

/// Static seed dataset for the isolated ClinicFlow demo.
///
/// This data is created in memory only. It is never written to Firebase.
class DemoData {
  DemoData._();

  static const clinicId = 'DEMO-CLINIC-001';

  static const user = AppUser(
    id: 'DEMO-USER-001',
    email: 'demo@clinicflow.app',
    name: 'Demo User',
    role: UserRole.admin,
    clinicId: clinicId,
  );

  static const doctors = <Doctor>[
    Doctor(id: 'DOC-001', name: 'Dr. Sara Ahmed', specialty: 'General Medicine', durationMinutes: 30),
    Doctor(id: 'DOC-002', name: 'Dr. Mohamed Ali', specialty: 'Dermatology', durationMinutes: 30),
    Doctor(id: 'DOC-003', name: 'Dr. Huda Osman', specialty: 'Dental', durationMinutes: 45),
    Doctor(id: 'DOC-004', name: 'Dr. Karim Hassan', specialty: 'Pediatrics', durationMinutes: 30),
    Doctor(id: 'DOC-005', name: 'Dr. Layla Ibrahim', specialty: 'Orthopedics', durationMinutes: 45),
    Doctor(id: 'DOC-006', name: 'Dr. Omar Musa', specialty: 'Cardiology', durationMinutes: 60),
  ];

  static const services = <MedicalService>[
    MedicalService(id: 'SERVICE-001', name: 'General Consultation', price: 35),
    MedicalService(id: 'SERVICE-002', name: 'Dermatology Consultation', price: 50),
    MedicalService(id: 'SERVICE-003', name: 'Dental Cleaning', price: 60),
    MedicalService(id: 'SERVICE-004', name: 'Pediatric Checkup', price: 40),
    MedicalService(id: 'SERVICE-005', name: 'Orthopedic Assessment', price: 75),
    MedicalService(id: 'SERVICE-006', name: 'Cardiology Screening', price: 90),
  ];

  static List<Appointment> appointments() {
    final today = DateTime.now();
    DateTime date(int offset) =>
        DateTime(today.year, today.month, today.day + offset);

    return [
      Appointment(id: 'DEMO-APT-001', number: 'APT-DEMO-001', doctor: doctors[0], service: services[0], date: date(0), startTime: '09:00', status: AppointmentStatus.completed),
      Appointment(id: 'DEMO-APT-002', number: 'APT-DEMO-002', doctor: doctors[1], service: services[1], date: date(0), startTime: '11:30', status: AppointmentStatus.scheduled),
      Appointment(id: 'DEMO-APT-003', number: 'APT-DEMO-003', doctor: doctors[2], service: services[2], date: date(0), startTime: '14:00', status: AppointmentStatus.scheduled),
      Appointment(id: 'DEMO-APT-004', number: 'APT-DEMO-004', doctor: doctors[3], service: services[3], date: date(1), startTime: '10:00', status: AppointmentStatus.scheduled),
      Appointment(id: 'DEMO-APT-005', number: 'APT-DEMO-005', doctor: doctors[4], service: services[4], date: date(2), startTime: '15:30', status: AppointmentStatus.scheduled),
      Appointment(id: 'DEMO-APT-006', number: 'APT-DEMO-006', doctor: doctors[5], service: services[5], date: date(3), startTime: '08:30', status: AppointmentStatus.scheduled),
      Appointment(id: 'DEMO-APT-007', number: 'APT-DEMO-007', doctor: doctors[0], service: services[0], date: date(-1), startTime: '16:00', status: AppointmentStatus.cancelled),
      Appointment(id: 'DEMO-APT-008', number: 'APT-DEMO-008', doctor: doctors[2], service: services[2], date: date(5), startTime: '13:00', status: AppointmentStatus.scheduled),
    ];
  }
}
