import '../core/utils/date_utils.dart';

class DietPlanModel {
  final String id;
  final String trainerId;
  final String? trainerName;
  final String? trainerEmail;
  final String memberId;
  final String? memberName;
  final String? memberEmail;
  final String dietDay; // MONDAY, TUESDAY, etc.
  final String mealType; // BREAKFAST, LUNCH, DINNER, SNACK
  final String foodName;
  final int calories;
  final double protein;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DietPlanModel({
    required this.id,
    required this.trainerId,
    this.trainerName,
    this.trainerEmail,
    required this.memberId,
    this.memberName,
    this.memberEmail,
    required this.dietDay,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory DietPlanModel.fromMap(Map<String, dynamic> map, String docId) {
    return DietPlanModel(
      id: docId,
      trainerId: map['trainer_id'] ?? '',
      trainerName: map['trainer_name'],
      trainerEmail: map['trainer_email'],
      memberId: map['member_id'] ?? '',
      memberName: map['member_name'],
      memberEmail: map['member_email'],
      dietDay: (map['diet_day'] ?? 'MONDAY').toString().toUpperCase(),
      mealType: (map['meal_type'] ?? 'BREAKFAST').toString().toUpperCase(),
      foodName: map['food_name'] ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'trainer_email': trainerEmail,
      'member_id': memberId,
      'member_name': memberName,
      'member_email': memberEmail,
      'diet_day': dietDay,
      'meal_type': mealType,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
