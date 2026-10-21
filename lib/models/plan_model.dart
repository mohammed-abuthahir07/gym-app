import '../core/utils/date_utils.dart';

class PlanModel {
  final String id;
  final String name;
  final String description;
  final int durationValue;
  final String durationUnit; // DAY, MONTH, YEAR
  final double price;
  final String extraFeatures;
  final String status; // ACTIVE, INACTIVE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationValue,
    required this.durationUnit,
    required this.price,
    required this.extraFeatures,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory PlanModel.fromMap(Map<String, dynamic> map, String docId) {
    return PlanModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      durationValue: (map['duration_value'] as num?)?.toInt() ?? 1,
      durationUnit: (map['duration_unit'] ?? 'MONTH').toString().toUpperCase(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      extraFeatures: map['extra_features'] ?? '',
      status: (map['status'] ?? 'ACTIVE').toString().toUpperCase(),
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'duration_value': durationValue,
      'duration_unit': durationUnit,
      'price': price,
      'extra_features': extraFeatures,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
