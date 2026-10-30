import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/models.dart';
import 'demo_data.dart';

abstract interface class ClinicRepository {
  Stream<AppUser?> watchCurrentUser();
  AppUser? get currentUser;
  Future<void> signIn(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> linkGuestAccount(String email, String password);
  Future<void> signOut();
  Future<void> signInAsDemoGuest();
  Future<void> startGuestSession(String clinicId);
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
        if (u.isAnonymous) {
          yield null;
          continue;
        }
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
  Future<void> sendPasswordReset(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty ||
        !RegExp(r'^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$').hasMatch(normalized)) {
      throw ArgumentError('Enter a valid email address.');
    }
    await _auth.sendPasswordResetEmail(email: normalized);
  }

  @override
  Future<void> linkGuestAccount(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty ||
        !RegExp(r'^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$').hasMatch(normalized)) {
      throw ArgumentError('Enter a valid email address.');
    }
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }

    var user = _auth.currentUser;
    if (user == null) {
      throw StateError('Your guest session has expired. Sign in again.');
    }

    final hasPasswordProvider =
        user.providerData.any((provider) => provider.providerId == 'password');
    if (user.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: normalized,
        password: password,
      );
      final linked = await user.linkWithCredential(credential);
      user = linked.user;
      if (user == null) {
        throw StateError('Firebase did not return the linked account.');
      }
    } else if (!hasPasswordProvider ||
        (user.email ?? '').trim().toLowerCase() != normalized) {
      throw StateError(
        'This session is already linked to a different sign-in method or email.',
      );
    }

    // Finalization is intentionally safe to retry. If the Auth link succeeds
    // but the callable request fails, a second attempt resumes from this point
    // rather than trying to link the credential a second time.
    await user.getIdToken(true);
    await FirebaseFunctions.instance
        .httpsCallable('finalizeGuestAccountLink')
        .call();

    final profile = await _firestore.collection('users').doc(user.uid).get();
    final data = profile.data();
    if (!profile.exists || data == null) {
      throw StateError('The linked account profile could not be loaded.');
    }
    _currentUser = AppUser.fromMap(
      user.uid,
      data,
      fallbackEmail: user.email ?? normalized,
    );
    _clinicId = _currentUser!.clinicId;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _clinicId = null;
  }

  @override
  Future<void> signInAsDemoGuest() async {
    throw UnsupportedError('Demo guest sign-in is only available in demo mode.');
  }

  @override
  Future<void> startGuestSession(String clinicId) async {
    final credential = await _auth.signInAnonymously();
    try {
      await FirebaseFunctions.instance.httpsCallable('startGuestProfile').call({
        'clinicId': clinicId,
      });
      final user = credential.user;
      if (user == null) throw StateError('Guest authentication failed.');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        throw StateError('Guest profile could not be initialized.');
      }
      _currentUser = AppUser.fromMap(user.uid, data, fallbackEmail: '');
      _clinicId = clinicId;
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
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

    final timeParts = startTime.split(':');
    if (timeParts.length != 2) {
      throw ArgumentError.value(startTime, 'startTime', 'Expected HH:mm.');
    }
    final startMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
    final endMinutes = startMinutes + doctor.durationMinutes;
    if (endMinutes >= 24 * 60) {
      throw ArgumentError('Appointment duration must finish before midnight.');
    }
    String formatMinutes(int value) =>
        '${(value ~/ 60).toString().padLeft(2, '0')}:'
        '${(value % 60).toString().padLeft(2, '0')}';

    final datePart = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final result = await FirebaseFunctions.instance
        .httpsCallable('createAppointment')
        .call<Map<String, dynamic>>({
      'clinicId': u.clinicId,
      'patientId': u.id,
      'doctorId': doctor.id,
      'serviceId': service.id,
      'appointmentDate': datePart,
      'startTime': startTime,
      'endTime': formatMinutes(endMinutes),
    });
    final id = result.data['appointmentId'] as String?;
    if (id == null || id.isEmpty) {
      throw StateError('The booking service did not return an appointment ID.');
    }

    final dateCompact = datePart.replaceAll('-', '');
    return Appointment(
      id: id,
      number: 'APT-$dateCompact-${id.substring(0, id.length < 6 ? id.length : 6).toUpperCase()}',
      doctor: doctor,
      service: service,
      date: DateTime(date.year, date.month, date.day),
      startTime: startTime,
      status: AppointmentStatus.scheduled,
    );
  }
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
  Future<void> sendPasswordReset(String email) async {
    throw UnsupportedError('Password recovery is unavailable in offline demo mode.');
  }

  @override
  Future<void> linkGuestAccount(String email, String password) async {
    throw UnsupportedError('Account linking is unavailable in offline demo mode.');
  }

  @override
  Future<void> signInAsDemoGuest() async {
    _user = DemoData.user;
    _appointments
      ..clear()
      ..addAll(DemoData.appointments());
  }

  @override
  Future<void> startGuestSession(String clinicId) async {
    throw UnsupportedError('Choose Try Demo for the offline sample environment.');
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
    if (_user == null) throw StateError('Enter demo mode first.');
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
