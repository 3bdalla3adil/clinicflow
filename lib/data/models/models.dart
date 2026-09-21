import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, reception, doctor, accountant, patient }

extension UserRoleX on UserRole {
  static UserRole fromValue(String? value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => UserRole.patient,
      );
}

enum AppointmentStatus { scheduled, checkedIn, inConsultation, completed, cancelled, noShow }

class AppUser {
  const AppUser({required this.id, required this.email, required this.name, required this.role, required this.clinicId});
  final String id, email, name, clinicId;
  final UserRole role;
  factory AppUser.fromMap(String id, Map<String,dynamic> data, {String fallbackEmail=''}) => AppUser(
    id:id, email:(data['email'] as String?) ?? fallbackEmail,
    name:(data['name'] as String?) ?? 'ClinicFlow User',
    role:UserRoleX.fromValue(data['role'] as String?),
    clinicId:(data['clinicId'] as String?) ?? '',
  );
}

class Doctor {
  const Doctor({required this.id,required this.name,required this.specialty,required this.durationMinutes});
  final String id,name,specialty; final int durationMinutes;
  factory Doctor.fromMap(String id,Map<String,dynamic> d)=>Doctor(id:id,name:(d['name'] as String?)??'',specialty:(d['specialty'] as String?)??'',durationMinutes:(d['durationMinutes'] as num?)?.toInt()??30);
  Map<String,dynamic> toMap()=>{'name':name,'specialty':specialty,'durationMinutes':durationMinutes};
}

class MedicalService {
  const MedicalService({required this.id,required this.name,required this.price});
  final String id,name; final double price;
  factory MedicalService.fromMap(String id,Map<String,dynamic> d)=>MedicalService(id:id,name:(d['name'] as String?)??'',price:(d['price'] as num?)?.toDouble()??0);
  Map<String,dynamic> toMap()=>{'name':name,'price':price};
}

class Appointment {
  const Appointment({required this.id,required this.number,required this.doctor,required this.service,required this.date,required this.startTime,required this.status});
  final String id,number,startTime; final Doctor doctor; final MedicalService service; final DateTime date; final AppointmentStatus status;
  factory Appointment.fromDocument(QueryDocumentSnapshot<Map<String,dynamic>> doc){
    final d=doc.data();
    return Appointment(
      id:doc.id,number:(d['number'] as String?)??doc.id,
      doctor:Doctor.fromMap((d['doctorId'] as String?)??'',(d['doctor'] as Map<String,dynamic>?)??{}),
      service:MedicalService.fromMap((d['serviceId'] as String?)??'',(d['service'] as Map<String,dynamic>?)??{}),
      date:(d['date'] as Timestamp?)?.toDate()??DateTime.now(),
      startTime:(d['startTime'] as String?)??'',
      status:AppointmentStatus.values.firstWhere((s)=>s.name==d['status'],orElse:()=>AppointmentStatus.scheduled),
    );
  }
  Map<String,dynamic> toMap()=>{'number':number,'doctorId':doctor.id,'doctor':doctor.toMap(),'serviceId':service.id,'service':service.toMap(),'date':Timestamp.fromDate(date),'startTime':startTime,'status':status.name};
}

String statusLabel(AppointmentStatus s)=>switch(s){
  AppointmentStatus.scheduled=>'Scheduled', AppointmentStatus.checkedIn=>'Checked in',
  AppointmentStatus.inConsultation=>'In consultation', AppointmentStatus.completed=>'Completed',
  AppointmentStatus.cancelled=>'Cancelled', AppointmentStatus.noShow=>'No show'
};
