import '../core/utils/date_utils.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'ADMIN', 'TRAINER', 'MEMBER'
  final String phone;
  final String? fitnessGoal;
  final String status; // 'ACTIVE', 'INACTIVE'
  final String? trainerId;
  final String? trainerName;
  final String? trainerEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.fitnessGoal,
    this.status = 'ACTIVE',
    this.trainerId,
    this.trainerName,
    this.trainerEmail,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isTrainer => role.toUpperCase() == 'TRAINER';
  bool get isMember => role.toUpperCase() == 'MEMBER';

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: (map['role'] ?? 'MEMBER').toString().toUpperCase(),
      phone: map['phone'] ?? '',
      fitnessGoal: map['fitness_goal'],
      status: (map['status'] ?? 'ACTIVE').toString().toUpperCase(),
      trainerId: map['trainer_id'],
      trainerName: map['trainer_name'],
      trainerEmail: map['trainer_email'],
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'fitness_goal': fitnessGoal,
      'status': status,
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'trainer_email': trainerEmail,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
