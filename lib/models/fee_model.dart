import '../core/utils/date_utils.dart';

class FeeModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String fitnessGoal;
  final double feeAmount;
  final String feeDate; // YYYY-MM-DD
  final String feeMonth; // e.g. SEPTEMBER
  final int feeYear; // e.g. 2026
  final String paymentStatus; // PAID, UNPAID, PENDING
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeeModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    this.fitnessGoal = '',
    required this.feeAmount,
    required this.feeDate,
    required this.feeMonth,
    required this.feeYear,
    this.paymentStatus = 'PAID',
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  factory FeeModel.fromMap(Map<String, dynamic> map, String docId) {
    return FeeModel(
      id: docId,
      memberId: map['member_id'] ?? '',
      memberName: map['member_name'] ?? '',
      memberEmail: map['member_email'] ?? '',
      fitnessGoal: map['fitness_goal'] ?? '',
      feeAmount: (map['fee_amount'] as num?)?.toDouble() ?? 0.0,
      feeDate: map['fee_date'] ?? '',
      feeMonth: (map['fee_month'] ?? '').toString().toUpperCase(),
      feeYear: (map['fee_year'] as num?)?.toInt() ?? DateTime.now().year,
      paymentStatus: (map['payment_status'] ?? 'PAID').toString().toUpperCase(),
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'member_email': memberEmail,
      'fitness_goal': fitnessGoal,
      'fee_amount': feeAmount,
      'fee_date': feeDate,
      'fee_month': feeMonth,
      'fee_year': feeYear,
      'payment_status': paymentStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
