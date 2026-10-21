import '../core/utils/date_utils.dart';

class MemberProfileModel {
  final String id;
  final String memberId;
  final String name;
  final String phone;
  final int age;
  final double height; // cm
  final double weight; // kg
  final String fitnessGoal;
  final String medicalNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MemberProfileModel({
    required this.id,
    required this.memberId,
    required this.name,
    required this.phone,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.medicalNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory MemberProfileModel.fromMap(Map<String, dynamic> map, String docId) {
    return MemberProfileModel(
      id: docId,
      memberId: map['member_id'] ?? docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      fitnessGoal: map['fitness_goal'] ?? '',
      medicalNotes: map['medical_notes'] ?? '',
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'name': name,
      'phone': phone,
      'age': age,
      'height': height,
      'weight': weight,
      'fitness_goal': fitnessGoal,
      'medical_notes': medicalNotes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
