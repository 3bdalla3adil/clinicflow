import '../../../../core/storage/cache_manager.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<void> cacheAppointments(
    String patientId,
    List<AppointmentModel> appointments,
  );
  List<AppointmentModel>? getCachedAppointments(String patientId);
  Future<void> clearCache(String patientId);
}

class AppointmentLocalDataSourceImpl
    implements AppointmentLocalDataSource {
  final CacheManager cacheManager;
  AppointmentLocalDataSourceImpl({required this.cacheManager});

  String _key(String patientId) => 'appointments_$patientId';

  @override
  Future<void> cacheAppointments(
    String patientId,
    List<AppointmentModel> appointments,
  ) async {
    final data = appointments.map((a) => a.toJson()).toList();
    await cacheManager.write(
      StorageKeys.appointmentsBox,
      _key(patientId),
      data,
      ttl: AppConstants.appointmentCacheTtl,
    );
  }

  @override
  List<AppointmentModel>? getCachedAppointments(String patientId) {
    final cached = cacheManager.read<List<dynamic>>(
      StorageKeys.appointmentsBox,
      _key(patientId),
    );
    if (cached == null) return null;
    return cached
        .map(
          (e) => AppointmentModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> clearCache(String patientId) =>
      cacheManager.invalidate(StorageKeys.appointmentsBox, _key(patientId));
}
