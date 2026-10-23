import '../core/utils/date_utils.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String instructions;
  final String imageUrl;
  final String videoUrl;
  final String difficulty; // BEGINNER, INTERMEDIATE, DIFFICULT
  final String status; // ACTIVE, INACTIVE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
    required this.imageUrl,
    required this.videoUrl,
    required this.difficulty,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive =>
      status.trim().toUpperCase() == 'ACTIVE' || status.trim().isEmpty;

  factory ExerciseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExerciseModel(
      id: docId,
      name: map['name']?.toString() ?? '',
      muscleGroup: map['muscle_group']?.toString() ?? '',
      equipment: map['equipment']?.toString() ?? '',
      instructions: map['instructions']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      videoUrl: map['video_url']?.toString() ?? '',
      difficulty: (map['difficulty'] ?? 'BEGINNER')
          .toString()
          .trim()
          .toUpperCase(),
      status: (map['status'] ?? 'ACTIVE').toString().trim().toUpperCase(),
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'instructions': instructions,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'difficulty': difficulty,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
