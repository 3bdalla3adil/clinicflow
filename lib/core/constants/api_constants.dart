import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.clinicflow.example.com/v1';
  static String get fhirUrl =>
      dotenv.env['FHIR_BASE_URL'] ??
      'https://fhir.clinicflow.example.com/fhir/R4';
  static String get odooUrl =>
      dotenv.env['ODOO_BASE_URL'] ?? 'https://erp.clinicflow.example.com';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String patients = '/patients';
  static String patient(String id) => '/patients/$id';
  static String patientAppointments(String id) =>
      '/patients/$id/appointments';
  static const String doctors = '/doctors';
  static String doctor(String id) => '/doctors/$id';
  static String doctorSchedule(String id) => '/doctors/$id/schedule';
  static String doctorSlots(String id) => '/doctors/$id/available-slots';
  static const String appointments = '/appointments';
  static String appointment(String id) => '/appointments/$id';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  static String reschedule(String id) => '/appointments/$id/reschedule';
  static const String fhirPatients = '/Patient';
  static const String fhirEncounters = '/Encounter';
  static const String fhirObservations = '/Observation';
  static const String fhirMedications = '/MedicationRequest';
  static const String fhirConditions = '/Condition';
  static const String medicalRecords = '/medical-records';
  static const String prescriptions = '/prescriptions';
  static const String labResults = '/lab-results';
  static const String invoices = '/billing/invoices';
  static String invoice(String id) => '/billing/invoices/$id';
  static const String clinics = '/clinics';
  static const String telehealthSessions = '/telehealth/sessions';
  static String joinSession(String id) => '/telehealth/sessions/$id/join';
  static const String notifications = '/notifications';
  static const String registerFcmToken = '/notifications/fcm-token';
  static const String odooAuthenticate = '/web/session/authenticate';
  static const String odooCallKw = '/web/dataset/call_kw';
}
