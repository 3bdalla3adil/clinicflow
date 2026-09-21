import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'demo_data.dart';

abstract interface class ClinicRepository {
  Stream<AppUser?> watchCurrentUser();
  AppUser? get currentUser;
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<void> signInAsDemoGuest();
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
  Future<void> signInAsDemoGuest() async {
    throw UnsupportedError('Demo guest sign-in is only available in demo mode.');
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
    throw UnsupportedError(
      'Use Try Demo to enter the isolated demo environment.',
    );
  }

  @override
  Future<void> signInAsDemoGuest() async {
    _user = DemoData.user;
    _appointments
      ..clear()
      ..addAll(DemoData.appointments());
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _appointments.clear();
  }

  @override
  Future<List<Doctor>> getDoctors() async => DemoData.doctors;

  @override
  Future<List<MedicalService>> getServices() async => DemoData.services;

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
    if (_user == null) {
      throw StateError('Enter demo mode first.');
    }

    final datePart = date.toIso8601String().substring(0, 10).replaceAll('-', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final appointment = Appointment(
      id: 'DEMO-APT-$timestamp',
      number: 'APT-$datePart-$timestamp',
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
