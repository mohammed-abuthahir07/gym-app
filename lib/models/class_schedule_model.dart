import '../core/utils/date_utils.dart';

class ClassScheduleModel {
  final String id;
  final String trainerId;
  final String? trainerName;
  final String? trainerEmail;
  final String title;
  final String classDate; // YYYY-MM-DD
  final String startTime; // HH:mm:ss
  final String endTime; // HH:mm:ss
  final int capacity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassScheduleModel({
    required this.id,
    required this.trainerId,
    this.trainerName,
    this.trainerEmail,
    required this.title,
    required this.classDate,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassScheduleModel.fromMap(Map<String, dynamic> map, String docId) {
    return ClassScheduleModel(
      id: docId,
      trainerId: map['trainer_id'] ?? '',
      trainerName: map['trainer_name'],
      trainerEmail: map['trainer_email'],
      title: map['title'] ?? '',
      classDate: map['class_date'] ?? '',
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 1,
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'trainer_email': trainerEmail,
      'title': title,
      'class_date': classDate,
      'start_time': startTime,
      'end_time': endTime,
      'capacity': capacity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
