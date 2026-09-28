import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment.dart';

class BookingParams {
  final String patientId;
  final String doctorId;
  final String clinicId;
  final DateTime scheduledAt;
  final AppointmentType type;
  final String? symptoms;
  final String? notes;
  const BookingParams({
    required this.patientId,
    required this.doctorId,
    required this.clinicId,
    required this.scheduledAt,
    required this.type,
    this.symptoms,
    this.notes,
  });
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });
}

abstract class AppointmentRepository {
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(
    String patientId,
  );
  Future<Either<Failure, List<Appointment>>> getPastAppointments(
    String patientId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, Appointment>> getAppointmentById(String id);
  Future<Either<Failure, Appointment>> bookAppointment(
    BookingParams params,
  );
  Future<Either<Failure, Appointment>> rescheduleAppointment(
    String id,
    DateTime newDateTime,
  );
  Future<Either<Failure, Unit>> cancelAppointment(
    String id, {
    String? reason,
  });
  Future<Either<Failure, List<TimeSlot>>> getAvailableSlots(
    String doctorId,
    DateTime date,
  );
}
