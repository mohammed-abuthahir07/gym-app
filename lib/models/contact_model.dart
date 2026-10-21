import '../core/utils/date_utils.dart';

class ContactModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String status; // NEW, READ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    this.status = 'NEW',
    this.createdAt,
    this.updatedAt,
  });

  bool get isRead => status.toUpperCase() == 'READ';

  factory ContactModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContactModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      message: map['message'] ?? '',
      status: (map['status'] ?? 'NEW').toString().toUpperCase(),
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
