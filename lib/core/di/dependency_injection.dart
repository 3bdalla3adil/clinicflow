import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../security/secure_storage.dart';
import '../security/biometric_service.dart';
import '../security/secure_logger.dart';
import '../connectivity/connectivity_service.dart';
import '../storage/cache_manager.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/refresh_token_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/appointments/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointments/data/datasources/appointment_local_datasource.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/get_upcoming_appointments_usecase.dart';
import '../../features/appointments/domain/usecases/book_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/cancel_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/reschedule_appointment_usecase.dart';
import '../../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/doctors/data/datasources/doctor_remote_datasource.dart';
import '../../features/doctors/data/repositories/doctor_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctor_repository.dart';
import '../../features/doctors/domain/usecases/get_doctors_usecase.dart';
import '../../features/doctors/domain/usecases/get_doctor_schedule_usecase.dart';
import '../../features/doctors/presentation/bloc/doctor_bloc.dart';
import '../../features/medical_records/data/datasources/emr_remote_datasource.dart';
import '../../features/medical_records/data/repositories/emr_repository_impl.dart';
import '../../features/medical_records/domain/repositories/emr_repository.dart';
import '../../features/medical_records/domain/usecases/get_medical_records_usecase.dart';
import '../../features/medical_records/presentation/bloc/emr_bloc.dart';
import '../../features/prescriptions/data/datasources/prescription_remote_datasource.dart';
import '../../features/prescriptions/data/repositories/prescription_repository_impl.dart';
import '../../features/prescriptions/domain/repositories/prescription_repository.dart';
import '../../features/prescriptions/domain/usecases/get_prescriptions_usecase.dart';
import '../../features/prescriptions/presentation/bloc/prescription_bloc.dart';
import '../../features/billing/data/datasources/billing_remote_datasource.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/billing/domain/usecases/get_invoices_usecase.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<ConnectivityService>()),
  );
  getIt.registerLazySingleton<CacheManager>(() => CacheManager());
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: getIt<SecureStorageService>()),
  );

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => RefreshTokenUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Appointments
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSourceImpl(
      cacheManager: getIt<CacheManager>(),
    ),
  );
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      remoteDataSource: getIt<AppointmentRemoteDataSource>(),
      localDataSource: getIt<AppointmentLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetUpcomingAppointmentsUseCase(getIt<AppointmentRepository>()),
  );
  getIt.registerLazySingleton(
    () => BookAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  getIt.registerLazySingleton(
    () => CancelAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  getIt.registerLazySingleton(
    () => RescheduleAppointmentUseCase(getIt<AppointmentRepository>()),
  );
  getIt.registerFactory<AppointmentBloc>(
    () => AppointmentBloc(
      getUpcoming: getIt<GetUpcomingAppointmentsUseCase>(),
      bookAppointment: getIt<BookAppointmentUseCase>(),
      cancelAppointment: getIt<CancelAppointmentUseCase>(),
      rescheduleAppointment: getIt<RescheduleAppointmentUseCase>(),
    ),
  );

  // Dashboard
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      getUpcomingAppointments: getIt<GetUpcomingAppointmentsUseCase>(),
    ),
  );

  // Doctors
  getIt.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(
      remoteDataSource: getIt<DoctorRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetDoctorsUseCase(getIt<DoctorRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDoctorScheduleUseCase(getIt<DoctorRepository>()),
  );
  getIt.registerFactory<DoctorBloc>(
    () => DoctorBloc(
      getDoctors: getIt<GetDoctorsUseCase>(),
      getDoctorSchedule: getIt<GetDoctorScheduleUseCase>(),
    ),
  );

  // EMR
  getIt.registerLazySingleton<EmrRemoteDataSource>(
    () => EmrRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<EmrRepository>(
    () => EmrRepositoryImpl(
      remoteDataSource: getIt<EmrRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetMedicalRecordsUseCase(getIt<EmrRepository>()),
  );
  getIt.registerFactory<EmrBloc>(
    () => EmrBloc(getMedicalRecords: getIt<GetMedicalRecordsUseCase>()),
  );

  // Prescriptions
  getIt.registerLazySingleton<PrescriptionRemoteDataSource>(
    () => PrescriptionRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<PrescriptionRepository>(
    () => PrescriptionRepositoryImpl(
      remoteDataSource: getIt<PrescriptionRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetPrescriptionsUseCase(getIt<PrescriptionRepository>()),
  );
  getIt.registerFactory<PrescriptionBloc>(
    () => PrescriptionBloc(
      getPrescriptions: getIt<GetPrescriptionsUseCase>(),
    ),
  );

  // Billing
  getIt.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(
      remoteDataSource: getIt<BillingRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetInvoicesUseCase(getIt<BillingRepository>()),
  );
  getIt.registerFactory<BillingBloc>(
    () => BillingBloc(getInvoices: getIt<GetInvoicesUseCase>()),
  );
}
