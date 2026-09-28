import 'package:equatable/equatable.dart';

enum RecordType {
  encounter,
  labResult,
  imaging,
  procedure,
  vaccination,
  allergy,
  vitalSigns,
  dischargeSummary,
}

class MedicalRecord extends Equatable {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? doctorName;
  final RecordType type;
  final String title;
  final String? description;
  final String? diagnosis;
  final DateTime recordDate;
  final DateTime createdAt;
  final List<String> attachmentUrls;
  final Map<String, String> metadata;
  final bool isConfidential;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.doctorName,
    required this.type,
    required this.title,
    this.description,
    this.diagnosis,
    required this.recordDate,
    required this.createdAt,
    this.attachmentUrls = const [],
    this.metadata = const {},
    this.isConfidential = false,
  });

  @override
  List<Object?> get props => [id, patientId, type, recordDate];
}
