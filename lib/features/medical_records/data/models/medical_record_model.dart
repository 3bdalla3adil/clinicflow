import '../../domain/entities/medical_record.dart';

class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.id,
    required super.patientId,
    super.doctorId,
    super.doctorName,
    required super.type,
    required super.title,
    super.description,
    super.diagnosis,
    required super.recordDate,
    required super.createdAt,
    super.attachmentUrls,
    super.metadata,
    super.isConfidential,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> j) =>
      MedicalRecordModel(
        id: j['id'] as String,
        patientId: j['patient_id'] as String,
        doctorId: j['doctor_id'] as String?,
        doctorName: j['doctor_name'] as String?,
        type: _parseType(j['type'] as String?),
        title: j['title'] as String? ?? '',
        description: j['description'] as String?,
        diagnosis: j['diagnosis'] as String?,
        recordDate: DateTime.parse(j['record_date'] as String),
        createdAt: DateTime.parse(
          j['created_at'] as String? ??
              DateTime.now().toIso8601String(),
        ),
        attachmentUrls:
            (j['attachment_urls'] as List<dynamic>?)
                    ?.cast<String>() ??
                [],
        isConfidential: j['is_confidential'] as bool? ?? false,
      );

  static RecordType _parseType(String? t) {
    switch (t) {
      case 'lab_result':
        return RecordType.labResult;
      case 'imaging':
        return RecordType.imaging;
      case 'vaccination':
        return RecordType.vaccination;
      case 'allergy':
        return RecordType.allergy;
      case 'vital_signs':
        return RecordType.vitalSigns;
      case 'discharge_summary':
        return RecordType.dischargeSummary;
      default:
        return RecordType.encounter;
    }
  }
}
