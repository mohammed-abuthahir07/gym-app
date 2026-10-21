import '../core/utils/date_utils.dart';

class CheatDayModel {
  final String id;
  final String memberId;
  final String? memberName;
  final String? memberEmail;
  final String cheatDate; // YYYY-MM-DD
  final String foodName;
  final String quantity;
  final int calories;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CheatDayModel({
    required this.id,
    required this.memberId,
    this.memberName,
    this.memberEmail,
    required this.cheatDate,
    required this.foodName,
    required this.quantity,
    required this.calories,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory CheatDayModel.fromMap(Map<String, dynamic> map, String docId) {
    return CheatDayModel(
      id: docId,
      memberId: map['member_id'] ?? '',
      memberName: map['member_name'],
      memberEmail: map['member_email'],
      cheatDate: map['cheat_date'] ?? '',
      foodName: map['food_name'] ?? '',
      quantity: map['quantity'] ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      notes: map['notes'],
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'member_email': memberEmail,
      'cheat_date': cheatDate,
      'food_name': foodName,
      'quantity': quantity,
      'calories': calories,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
