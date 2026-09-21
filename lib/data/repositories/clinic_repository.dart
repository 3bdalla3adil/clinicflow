import '../models/models.dart';

abstract interface class ClinicRepository {
  Stream<AppUser?> watchCurrentUser();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<List<Doctor>> getDoctors();
  Future<List<MedicalService>> getServices();
  Future<List<Appointment>> getAppointments({String? patientId});
  Future<Appointment> createAppointment(
      {required Doctor doctor,
      required MedicalService service,
      required DateTime date,
      required String startTime});
}

class DemoClinicRepository implements ClinicRepository {
  final _doctors = const [
    Doctor(
        id: 'DOC-001',
        name: 'Dr. Sara Ahmed',
        specialty: 'General Medicine',
        durationMinutes: 30),
    Doctor(
        id: 'DOC-002',
        name: 'Dr. Mohamed Ali',
        specialty: 'Dermatology',
        durationMinutes: 30),
    Doctor(
        id: 'DOC-003',
        name: 'Dr. Huda Osman',
        specialty: 'Dental',
        durationMinutes: 45)
  ];
  final _services = const [
    MedicalService(id: 'SERVICE-001', name: 'General Consultation', price: 35),
    MedicalService(
        id: 'SERVICE-002', name: 'Dermatology Consultation', price: 50),
    MedicalService(id: 'SERVICE-003', name: 'Dental Consultation', price: 60)
  ];
  final List<Appointment> _appointments = [];
  AppUser? _user;
  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _user;
  }

  @override
  Future<void> signIn(String email, String password) async {
    _user = AppUser(
        id: 'PAT-DEMO-001',
        email: email,
        name: 'Demo Patient',
        role: UserRole.patient,
        clinicId: 'CLINIC-001');
  }

  @override
  Future<void> signOut() async => _user = null;
  @override
  Future<List<Doctor>> getDoctors() async => _doctors;
  @override
  Future<List<MedicalService>> getServices() async => _services;
  @override
  Future<List<Appointment>> getAppointments({String? patientId}) async =>
      List.unmodifiable(_appointments);
  @override
  Future<Appointment> createAppointment(
      {required Doctor doctor,
      required MedicalService service,
      required DateTime date,
      required String startTime}) async {
    final a = Appointment(
        id: 'APT-${DateTime.now().millisecondsSinceEpoch}',
        number:
            'APT-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
        doctor: doctor,
        service: service,
        date: date,
        startTime: startTime,
        status: AppointmentStatus.scheduled);
    _appointments.add(a);
    return a;
  }
}
