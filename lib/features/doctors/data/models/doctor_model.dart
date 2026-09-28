import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.fullName,
    required super.specialization,
    super.avatarUrl,
    super.bio,
    super.rating,
    super.reviewCount,
    super.experienceYears,
    required super.consultationFee,
    required super.clinicId,
    required super.clinicName,
    super.phone,
    super.isAvailableToday,
    super.languages,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> j) => DoctorModel(
        id: j['id'] as String,
        fullName: j['full_name'] as String,
        specialization: j['specialization'] as String,
        avatarUrl: j['avatar_url'] as String?,
        bio: j['bio'] as String?,
        rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: j['review_count'] as int? ?? 0,
        experienceYears: j['experience_years'] as int? ?? 0,
        consultationFee:
            (j['consultation_fee'] as num?)?.toDouble() ?? 0.0,
        clinicId: j['clinic_id'] as String? ?? '',
        clinicName: j['clinic_name'] as String? ?? '',
        phone: j['phone'] as String?,
        isAvailableToday: j['is_available_today'] as bool? ?? false,
        languages:
            (j['languages'] as List<dynamic>?)?.cast<String>() ??
                ['ar', 'en'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'specialization': specialization,
        'rating': rating,
        'consultation_fee': consultationFee,
      };
}
