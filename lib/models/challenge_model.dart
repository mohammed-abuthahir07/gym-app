import '../core/utils/date_utils.dart';

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String reward;
  final String status; // ACTIVE, INACTIVE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.reward,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive =>
      status.trim().toUpperCase() == 'ACTIVE' || status.trim().isEmpty;

  factory ChallengeModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChallengeModel(
      id: docId,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      reward: map['reward']?.toString() ?? '',
      status: (map['status'] ?? 'ACTIVE').toString().trim().toUpperCase(),
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'reward': reward,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
