import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String fullName;
  final String specialization;
  final String? avatarUrl;
  final String? bio;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final String clinicId;
  final String clinicName;
  final String? phone;
  final bool isAvailableToday;
  final List<String> languages;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.avatarUrl,
    this.bio,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.experienceYears = 0,
    required this.consultationFee,
    required this.clinicId,
    required this.clinicName,
    this.phone,
    this.isAvailableToday = false,
    this.languages = const ['ar', 'en'],
  });

  @override
  List<Object?> get props => [id, specialization];
}
