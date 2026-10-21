import '../core/utils/date_utils.dart';

class WorkoutExerciseModel {
  final String id;
  final String workoutPlanId;
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final String equipment;
  final String instructions;
  final String imageUrl;
  final String videoUrl;
  final String difficulty;
  final String workoutDay; // MONDAY, TUESDAY, etc.
  final int sets;
  final int reps;
  final int durationMinutes;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutExerciseModel({
    required this.id,
    required this.workoutPlanId,
    required this.exerciseId,
    required this.exerciseName,
    this.muscleGroup = '',
    this.equipment = '',
    this.instructions = '',
    this.imageUrl = '',
    this.videoUrl = '',
    this.difficulty = 'INTERMEDIATE',
    required this.workoutDay,
    required this.sets,
    required this.reps,
    required this.durationMinutes,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> map, String docId) {
    return WorkoutExerciseModel(
      id: docId,
      workoutPlanId: map['workout_plan_id'] ?? '',
      exerciseId: map['exercise_id'] ?? '',
      exerciseName: map['exercise_name'] ?? '',
      muscleGroup: map['muscle_group'] ?? '',
      equipment: map['equipment'] ?? '',
      instructions: map['instructions'] ?? '',
      imageUrl: map['image_url'] ?? '',
      videoUrl: map['video_url'] ?? '',
      difficulty: map['difficulty'] ?? 'INTERMEDIATE',
      workoutDay: (map['workout_day'] ?? 'MONDAY').toString().toUpperCase(),
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] as num?)?.toInt() ?? 10,
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 15,
      notes: map['notes'] ?? '',
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workout_plan_id': workoutPlanId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'instructions': instructions,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'difficulty': difficulty,
      'workout_day': workoutDay,
      'sets': sets,
      'reps': reps,
      'duration_minutes': durationMinutes,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class WorkoutPlanModel {
  final String id;
  final String trainerId;
  final String memberId;
  final String planName;
  final String? trainerName;
  final String? trainerEmail;
  final String? memberName;
  final String? memberEmail;
  final List<WorkoutExerciseModel> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutPlanModel({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.planName,
    this.trainerName,
    this.trainerEmail,
    this.memberName,
    this.memberEmail,
    this.exercises = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutPlanModel.fromMap(
    Map<String, dynamic> map,
    String docId, {
    List<WorkoutExerciseModel> exercises = const [],
  }) {
    return WorkoutPlanModel(
      id: docId,
      trainerId: map['trainer_id'] ?? '',
      memberId: map['member_id'] ?? '',
      planName: map['plan_name'] ?? '',
      trainerName: map['trainer_name'],
      trainerEmail: map['trainer_email'],
      memberName: map['member_name'],
      memberEmail: map['member_email'],
      exercises: exercises,
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainer_id': trainerId,
      'member_id': memberId,
      'plan_name': planName,
      'trainer_name': trainerName,
      'trainer_email': trainerEmail,
      'member_name': memberName,
      'member_email': memberEmail,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class WorkoutCompletionModel {
  final String id;
  final String memberId;
  final String workoutPlanExerciseId;
  final String completedDate; // YYYY-MM-DD
  final DateTime? completedAt;

  WorkoutCompletionModel({
    required this.id,
    required this.memberId,
    required this.workoutPlanExerciseId,
    required this.completedDate,
    this.completedAt,
  });

  factory WorkoutCompletionModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return WorkoutCompletionModel(
      id: docId,
      memberId: map['member_id'] ?? '',
      workoutPlanExerciseId: map['workout_plan_exercise_id'] ?? '',
      completedDate: map['completed_date'] ?? '',
      completedAt: AppDateUtils.parseDateTime(map['completed_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'member_id': memberId,
      'workout_plan_exercise_id': workoutPlanExerciseId,
      'completed_date': completedDate,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
