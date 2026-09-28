import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

abstract class AppL10n {
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
  static const Locale defaultLocale = Locale('ar');
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _strings = {
    'ar': {
      'appTitle': 'كلينيك فلو',
      'welcome': 'مرحبًا',
      'welcomeUser': 'مرحبًا، {name}',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'fullName': 'الاسم الكامل',
      'phone': 'رقم الهاتف',
      'dateOfBirth': 'تاريخ الميلاد',
      'gender': 'الجنس',
      'male': 'ذكر',
      'female': 'أنثى',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'delete': 'حذف',
      'edit': 'تعديل',
      'loading': 'جارٍ التحميل...',
      'retry': 'إعادة المحاولة',
      'error': 'حدث خطأ',
      'errorGeneric': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      'noInternet': 'لا يوجد اتصال بالإنترنت',
      'offlineMode': 'وضع غير متصل — يتم عرض البيانات المخزنة محليًا',
      'sessionExpired': 'انتهت الجلسة. يرجى تسجيل الدخول مجددًا.',
      'dashboard': 'الرئيسية',
      'appointments': 'المواعيد',
      'upcomingAppointments': 'المواعيد القادمة',
      'pastAppointments': 'المواعيد السابقة',
      'bookAppointment': 'احجز موعدًا',
      'reschedule': 'إعادة الجدولة',
      'cancelAppointment': 'إلغاء الموعد',
      'noAppointments': 'لا توجد مواعيد',
      'noAppointmentsDesc':
          'ليس لديك مواعيد قادمة. احجز موعدك الأول الآن.',
      'appointmentConfirmed': 'تم تأكيد الموعد',
      'appointmentCancelled': 'تم إلغاء الموعد',
      'appointmentPending': 'الموعد قيد الانتظار',
      'appointmentCompleted': 'اكتمل الموعد',
      'doctors': 'الأطباء',
      'specialization': 'التخصص',
      'availableSlots': 'المواعيد المتاحة',
      'selectDate': 'اختر التاريخ',
      'selectTime': 'اختر الوقت',
      'selectDoctor': 'اختر الطبيب',
      'selectClinic': 'اختر العيادة',
      'appointmentType': 'نوع الموعد',
      'inPerson': 'حضوري',
      'telehealth': 'عن بُعد',
      'medicalRecords': 'السجلات الطبية',
      'prescriptions': 'الوصفات الطبية',
      'labResults': 'نتائج المختبر',
      'billing': 'الفواتير',
      'paid': 'مدفوع',
      'unpaid': 'غير مدفوع',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'today': 'اليوم',
      'tomorrow': 'غدًا',
      'search': 'بحث',
      'searchDoctor': 'البحث عن طبيب',
      'noResults': 'لا توجد نتائج',
      'viewAll': 'عرض الكل',
      'close': 'إغلاق',
      'next': 'التالي',
      'back': 'رجوع',
      'done': 'تم',
      'required': 'مطلوب',
      'invalidEmail': 'البريد الإلكتروني غير صحيح',
      'passwordTooShort': 'كلمة المرور قصيرة جدًا (8 أحرف على الأقل)',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'phiNotice': 'هذه معلومات طبية حساسة.',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'symptoms': 'الأعراض',
      'notes': 'ملاحظات',
      'consultationFee': 'رسوم الاستشارة',
      'duration': 'المدة',
      'minutes': 'دقيقة',
      'clinic': 'العيادة',
      'address': 'العنوان',
      'rating': 'التقييم',
      'experience': 'الخبرة',
      'years': 'سنوات',
      'about': 'نبذة',
      'bookNow': 'احجز الآن',
      'amount': 'المبلغ',
      'status': 'الحالة',
      'date': 'التاريخ',
      'time': 'الوقت',
      'doctor': 'الطبيب',
      'patient': 'المريض',
      'viewDetails': 'عرض التفاصيل',
      'medication': 'الدواء',
      'dosage': 'الجرعة',
      'frequency': 'التكرار',
      'diagnosis': 'التشخيص',
      'allergies': 'الحساسيات',
      'bloodType': 'فصيلة الدم',
      'weight': 'الوزن',
      'height': 'الطول',
      'age': 'العمر',
      'nationalId': 'رقم الهوية',
    },
    'en': {
      'appTitle': 'ClinicFlow',
      'welcome': 'Welcome',
      'welcomeUser': 'Welcome, {name}',
      'login': 'Sign In',
      'logout': 'Sign Out',
      'register': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'fullName': 'Full Name',
      'phone': 'Phone Number',
      'dateOfBirth': 'Date of Birth',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'retry': 'Retry',
      'error': 'Error',
      'errorGeneric': 'An unexpected error occurred. Please try again.',
      'noInternet': 'No internet connection',
      'offlineMode': 'Offline mode — showing locally cached data',
      'sessionExpired': 'Session expired. Please sign in again.',
      'dashboard': 'Home',
      'appointments': 'Appointments',
      'upcomingAppointments': 'Upcoming Appointments',
      'pastAppointments': 'Past Appointments',
      'bookAppointment': 'Book Appointment',
      'reschedule': 'Reschedule',
      'cancelAppointment': 'Cancel Appointment',
      'noAppointments': 'No Appointments',
      'noAppointmentsDesc':
          'You have no upcoming appointments. Book your first one now.',
      'appointmentConfirmed': 'Appointment Confirmed',
      'appointmentCancelled': 'Appointment Cancelled',
      'appointmentPending': 'Appointment Pending',
      'appointmentCompleted': 'Appointment Completed',
      'doctors': 'Doctors',
      'specialization': 'Specialization',
      'availableSlots': 'Available Slots',
      'selectDate': 'Select Date',
      'selectTime': 'Select Time',
      'selectDoctor': 'Select Doctor',
      'selectClinic': 'Select Clinic',
      'appointmentType': 'Appointment Type',
      'inPerson': 'In-Person',
      'telehealth': 'Telehealth',
      'medicalRecords': 'Medical Records',
      'prescriptions': 'Prescriptions',
      'labResults': 'Lab Results',
      'billing': 'Billing',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'notifications': 'Notifications',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'search': 'Search',
      'searchDoctor': 'Search for a doctor',
      'noResults': 'No results found',
      'viewAll': 'View All',
      'close': 'Close',
      'next': 'Next',
      'back': 'Back',
      'done': 'Done',
      'required': 'Required',
      'invalidEmail': 'Invalid email address',
      'passwordTooShort': 'Password too short (min 8 characters)',
      'passwordsDoNotMatch': 'Passwords do not match',
      'phiNotice': 'This is sensitive medical information.',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'symptoms': 'Symptoms',
      'notes': 'Notes',
      'consultationFee': 'Consultation Fee',
      'duration': 'Duration',
      'minutes': 'minutes',
      'clinic': 'Clinic',
      'address': 'Address',
      'rating': 'Rating',
      'experience': 'Experience',
      'years': 'years',
      'about': 'About',
      'bookNow': 'Book Now',
      'amount': 'Amount',
      'status': 'Status',
      'date': 'Date',
      'time': 'Time',
      'doctor': 'Doctor',
      'patient': 'Patient',
      'viewDetails': 'View Details',
      'medication': 'Medication',
      'dosage': 'Dosage',
      'frequency': 'Frequency',
      'diagnosis': 'Diagnosis',
      'allergies': 'Allergies',
      'bloodType': 'Blood Type',
      'weight': 'Weight',
      'height': 'Height',
      'age': 'Age',
      'nationalId': 'National ID',
    },
  };

  String translate(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['en']?[key] ?? key;

  String translateWithParams(String key, Map<String, String> params) {
    String v = translate(key);
    params.forEach((k, val) => v = v.replaceAll('{$k}', val));
    return v;
  }

  String get appTitle => translate('appTitle');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get noAppointments => translate('noAppointments');
  String get noAppointmentsDesc => translate('noAppointmentsDesc');
  String get upcomingAppointments => translate('upcomingAppointments');
  String get bookAppointment => translate('bookAppointment');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get dashboard => translate('dashboard');
  String get appointments => translate('appointments');
  String get doctors => translate('doctors');
  String get medicalRecords => translate('medicalRecords');
  String get prescriptions => translate('prescriptions');
  String get billing => translate('billing');
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get search => translate('search');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get viewAll => translate('viewAll');
  String get phiNotice => translate('phiNotice');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
