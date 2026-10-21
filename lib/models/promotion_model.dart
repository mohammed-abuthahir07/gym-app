import '../core/utils/date_utils.dart';

class PromotionModel {
  final String id;
  final String title;
  final String code;
  final String description;
  final double discount;
  final String discountType; // PERCENTAGE, FIXED
  final String startDate;
  final String endDate;
  final String status; // ACTIVE, INACTIVE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PromotionModel({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.discount,
    required this.discountType,
    required this.startDate,
    required this.endDate,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory PromotionModel.fromMap(Map<String, dynamic> map, String docId) {
    return PromotionModel(
      id: docId,
      title: map['title'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: (map['discount_type'] ?? 'PERCENTAGE')
          .toString()
          .toUpperCase(),
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'] ?? '',
      status: (map['status'] ?? 'ACTIVE').toString().toUpperCase(),
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'description': description,
      'discount': discount,
      'discount_type': discountType,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
