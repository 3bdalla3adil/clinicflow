abstract class AppConstants {
  static const String appName = 'ClinicFlow';
  static const String appVersion = '1.0.0';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const int tokenRefreshThresholdMinutes = 5;
  static const int otpLength = 6;
  static const Duration otpExpiry = Duration(minutes: 10);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration appointmentCacheTtl = Duration(hours: 1);
  static const Duration doctorCacheTtl = Duration(hours: 6);
  static const Duration profileCacheTtl = Duration(hours: 24);
  static const int syncBatchSize = 50;
  static const Duration syncInterval = Duration(minutes: 5);
  static const int pageSize = 20;
  static const int initialPage = 1;
  static const List<String> phiFields = [
    'name',
    'email',
    'phone',
    'dateOfBirth',
    'nhid',
    'diagnosis',
    'notes',
    'address',
    'nationalId',
  ];
  static const String displayDateFormat = 'yyyy-MM-dd';
  static const String displayTimeFormat = 'HH:mm';
  static const String apiDateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  static const int maxFileSizeMb = 10;
}
