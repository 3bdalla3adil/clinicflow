import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';

abstract interface class ClinicRepository {
  Stream<AppUser?> watchCurrentUser();
  AppUser? get currentUser;
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<List<Doctor>> getDoctors();
  Future<List<MedicalService>> getServices();
  Future<List<Appointment>> getAppointments({String? patientId});
  Future<Appointment> createAppointment({
    required Doctor doctor,
    required MedicalService service,
    required DateTime date,
    required String startTime,
  });
}

class FirebaseClinicRepository implements ClinicRepository {
  FirebaseClinicRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AppUser? _currentUser;
  String? _clinicId;

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    final id = _clinicId;
    if (id == null || id.isEmpty) {
      throw StateError('No clinic is assigned to this account.');
    }
    return _firestore.collection('clinics').doc(id).collection(name);
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    await for (final u in _auth.authStateChanges()) {
      if (u == null) {
        _currentUser = null;
        _clinicId = null;
        yield null;
        continue;
      }

      final doc = await _firestore.collection('users').doc(u.uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw StateError('Account is not provisioned in ClinicFlow.');
      }

      final data = doc.data();
      if (data == null) {
        await _auth.signOut();
        throw StateError('User document has no data.');
      }

      final user = AppUser.fromMap(
        u.uid,
        data,
        fallbackEmail: u.email ?? '',
      );
      _currentUser = user;
      _clinicId = user.clinicId;
      yield user;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final u = credential.user;
    if (u == null) {
      throw StateError('Authentication returned no user.');
    }

    final doc = await _firestore.collection('users').doc(u.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw StateError('Account is not provisioned in ClinicFlow.');
    }

    final data = doc.data();
    if (data == null) {
      await _auth.signOut();
      throw StateError('User document has no data.');
    }

    final user = AppUser.fromMap(
      u.uid,
      data,
      fallbackEmail: u.email ?? '',
    );
    _currentUser = user;
    _clinicId = user.clinicId;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _clinicId = null;
    await _auth.signOut();
  }

  @override
  Future<List<Doctor>> getDoctors() async {
    final snapshot = await _collection('doctors').get();
    return snapshot.docs
        .map((d) => Doctor.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<List<MedicalService>> getServices() async {
    final snapshot = await _collection('services').get();
    return snapshot.docs
        .map((d) => MedicalService.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<List<Appointment>> getAppointments({String? patientId}) async {
    Query<Map<String, dynamic>> q = _collection('appointments');
    if (patientId != null) {
      q = q.where('patientId', isEqualTo: patientId);
    }
    final snapshot = await q.orderBy('date').get();
    return snapshot.docs.map(Appointment.fromDocument).toList();
  }

  @override
  Future<Appointment> createAppointment({
    required Doctor doctor,
    required MedicalService service,
    required DateTime date,
    required String startTime,
  }) async {
    final u = _currentUser;
    if (u == null) {
      throw StateError('Sign in required.');
    }

    final ref = _collection('appointments').doc();
    final datePart = '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    final appointment = Appointment(
      id: ref.id,
      number: 'APT-$datePart-${DateTime.now().millisecondsSinceEpoch}',
      doctor: doctor,
      service: service,
      date: date,
      startTime: startTime,
      status: AppointmentStatus.scheduled,
    );

    await ref.set({
      ...appointment.toMap(),
      'patientId': u.id,
      'clinicId': u.clinicId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return appointment;
  }
}

class DemoCredential {
  const DemoCredential({
    required this.role,
    required this.name,
    required this.email,
    required this.password,
    required this.userId,
  });

  final UserRole role;
  final String name;
  final String email;
  final String password;
  final String userId;
}

class DemoClinicRepository implements ClinicRepository {
  static const demoCredentials = [
    DemoCredential(
      role: UserRole.admin,
      name: 'Demo Administrator',
      email: 'admin@demo.clinicflow.app',
      password: 'ClinicFlow@Admin2026',
      userId: 'DEMO-ADMIN-001',
    ),
    DemoCredential(
      role: UserRole.reception,
      name: 'Demo Receptionist',
      email: 'reception@demo.clinicflow.app',
      password: 'ClinicFlow@Reception2026',
      userId: 'DEMO-RECEPTION-001',
    ),
    DemoCredential(
      role: UserRole.doctor,
      name: 'Dr. Demo Doctor',
      email: 'doctor@demo.clinicflow.app',
      password: 'ClinicFlow@Doctor2026',
      userId: 'DEMO-DOCTOR-001',
    ),
    DemoCredential(
      role: UserRole.accountant,
      name: 'Demo Accountant',
      email: 'accountant@demo.clinicflow.app',
      password: 'ClinicFlow@Accountant2026',
      userId: 'DEMO-ACCOUNTANT-001',
    ),
    DemoCredential(
      role: UserRole.patient,
      name: 'Demo Patient',
      email: 'patient@demo.clinicflow.app',
      password: 'ClinicFlow@Patient2026',
      userId: 'DEMO-PATIENT-001',
    ),
  ];

  static const _doctors = [
    Doctor(
      id: 'DOC-001',
      name: 'Dr. Sara Ahmed',
      specialty: 'General Medicine',
      durationMinutes: 30,
    ),
    Doctor(
      id: 'DOC-002',
      name: 'Dr. Mohamed Ali',
      specialty: 'Dermatology',
      durationMinutes: 30,
    ),
    Doctor(
      id: 'DOC-003',
      name: 'Dr. Huda Osman',
      specialty: 'Dental',
      durationMinutes: 45,
    ),
  ];

  static const _services = [
    MedicalService(
      id: 'SERVICE-001',
      name: 'General Consultation',
      price: 35,
    ),
    MedicalService(
      id: 'SERVICE-002',
      name: 'Dermatology Consultation',
      price: 50,
    ),
    MedicalService(
      id: 'SERVICE-003',
      name: 'Dental Consultation',
      price: 60,
    ),
  ];

  final List<Appointment> _appointments = [];
  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _user;
  }

  @override
  Future<void> signIn(String email, String password) async {
    final trimmed = email.trim().toLowerCase();
    DemoCredential? match;
    for (final c in demoCredentials) {
      if (c.email == trimmed) {
        match = c;
        break;
      }
    }
    if (match == null || match.password != password) {
      throw StateError('Invalid demo credentials.');
    }
    _user = AppUser(
      id: match.userId,
      email: match.email,
      name: match.name,
      role: match.role,
      clinicId: 'DEMO-CLINIC-001',
    );
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<List<Doctor>> getDoctors() async => _doctors;

  @override
  Future<List<MedicalService>> getServices() async => _services;

  @override
  Future<List<Appointment>> getAppointments({String? patientId}) async =>
      List.unmodifiable(_appointments);

  @override
  Future<Appointment> createAppointment({
    required Doctor doctor,
    required MedicalService service,
    required DateTime date,
    required String startTime,
  }) async {
    final datePart = '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    final appointment = Appointment(
      id: 'APT-${DateTime.now().millisecondsSinceEpoch}',
      number: 'APT-$datePart',
      doctor: doctor,
      service: service,
      date: date,
      startTime: startTime,
      status: AppointmentStatus.scheduled,
    );
    _appointments.add(appointment);
    return appointment;
  }
}
