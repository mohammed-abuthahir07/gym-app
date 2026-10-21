import '../core/utils/date_utils.dart';

class ProgressModel {
  final String id;
  final String memberId;
  final String progressDate; // YYYY-MM-DD
  final double weight;
  final double bodyFat;
  final double waistCm;
  final double armsCm;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgressModel({
    required this.id,
    required this.memberId,
    required this.progressDate,
    required this.weight,
    required this.bodyFat,
    required this.waistCm,
    required this.armsCm,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProgressModel(
      id: docId,
      memberId: map['member_id'] ?? '',
      progressDate: map['progress_date'] ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      bodyFat: (map['body_fat'] as num?)?.toDouble() ?? 0.0,
      waistCm: (map['waist_cm'] as num?)?.toDouble() ?? 0.0,
      armsCm: (map['arms_cm'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'progress_date': progressDate,
      'weight': weight,
      'body_fat': bodyFat,
      'waist_cm': waistCm,
      'arms_cm': armsCm,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
