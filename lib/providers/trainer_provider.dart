import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/class_schedule_model.dart';
import '../models/workout_plan_model.dart';
import '../models/diet_plan_model.dart';
import '../models/cheat_day_model.dart';
import '../models/exercise_model.dart';
import '../core/utils/date_utils.dart';

class TrainerProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<UserModel> assignedMembers = [];
  List<ClassScheduleModel> schedules = [];
  List<WorkoutPlanModel> workoutPlans = [];
  List<DietPlanModel> dietPlans = [];
  List<CheatDayModel> cheatDays = [];
  List<ExerciseModel> availableExercises = [];

  // Metrics
  int assignedMembersCount = 0;
  int dietPlansCount = 0;
  int workoutPlansCount = 0;
  int todayWorkoutsCount = 0;

  Future<void> loadTrainerData(String trainerId) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      assignedMembers = await _service.getAssignedMembers(trainerId);
      schedules = await _service.getTrainerClassSchedules(trainerId);
      workoutPlans = await _service.getTrainerWorkoutPlans(trainerId);
      dietPlans = await _service.getTrainerDietPlans(trainerId);
      availableExercises = await _service.getActiveExercises();

      // Counts
      assignedMembersCount = assignedMembers.length;
      dietPlansCount = dietPlans.length;
      workoutPlansCount = workoutPlans.length;

      // Calculate today workouts
      final currentDay = AppDateUtils.currentDayName();
      int todayCount = 0;
      for (final plan in workoutPlans) {
        for (final ex in plan.exercises) {
          if (ex.workoutDay == currentDay) {
            todayCount++;
          }
        }
      }
      todayWorkoutsCount = todayCount;

      // Load cheat days for assigned members
      cheatDays.clear();
      for (final member in assignedMembers) {
        final memberCheatDays = await _service.getMemberCheatDays(member.id);
        cheatDays.addAll(memberCheatDays);
      }
      cheatDays.sort((a, b) => b.cheatDate.compareTo(a.cheatDate));
    } catch (e) {
      _errorMessage = 'Unable to load trainer workspace. Please check your connection and retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Schedules
  Future<void> addSchedule(ClassScheduleModel model) async {
    await _service.createClassSchedule(model);
    schedules = await _service.getTrainerClassSchedules(model.trainerId);
    notifyListeners();
  }

  Future<void> updateSchedule(ClassScheduleModel model) async {
    await _service.updateClassSchedule(model);
    schedules = await _service.getTrainerClassSchedules(model.trainerId);
    notifyListeners();
  }

  Future<void> deleteSchedule(String scheduleId, String trainerId) async {
    await _service.deleteClassSchedule(scheduleId);
    schedules = await _service.getTrainerClassSchedules(trainerId);
    notifyListeners();
  }

  // Workout Plans
  Future<void> createWorkoutPlan({
    required WorkoutPlanModel plan,
    required WorkoutExerciseModel starterExercise,
  }) async {
    await _service.createWorkoutPlan(plan, starterExercise);
    workoutPlans = await _service.getTrainerWorkoutPlans(plan.trainerId);
    workoutPlansCount = workoutPlans.length;
    notifyListeners();
  }

  Future<void> updateWorkoutPlanName(
    String planId,
    String newName,
    String trainerId,
  ) async {
    await _service.updateWorkoutPlanName(planId, newName);
    workoutPlans = await _service.getTrainerWorkoutPlans(trainerId);
    notifyListeners();
  }

  Future<void> deleteWorkoutPlan(String planId, String trainerId) async {
    await _service.deleteWorkoutPlan(planId);
    workoutPlans = await _service.getTrainerWorkoutPlans(trainerId);
    workoutPlansCount = workoutPlans.length;
    notifyListeners();
  }

  Future<void> addExerciseToPlan(
    WorkoutExerciseModel exercise,
    String trainerId,
  ) async {
    await _service.addExerciseToWorkoutPlan(exercise);
    workoutPlans = await _service.getTrainerWorkoutPlans(trainerId);
    notifyListeners();
  }

  Future<void> updateExerciseInPlan(
    WorkoutExerciseModel exercise,
    String trainerId,
  ) async {
    await _service.updateWorkoutPlanExercise(exercise);
    workoutPlans = await _service.getTrainerWorkoutPlans(trainerId);
    notifyListeners();
  }

  Future<void> deleteExerciseFromPlan(
    String planId,
    String exerciseId,
    String trainerId,
  ) async {
    await _service.deleteWorkoutPlanExercise(planId, exerciseId);
    workoutPlans = await _service.getTrainerWorkoutPlans(trainerId);
    notifyListeners();
  }

  // Diet Plans
  Future<void> addDietPlan(DietPlanModel model) async {
    await _service.createDietPlan(model);
    dietPlans = await _service.getTrainerDietPlans(model.trainerId);
    dietPlansCount = dietPlans.length;
    notifyListeners();
  }

  Future<void> updateDietPlan(DietPlanModel model) async {
    await _service.updateDietPlan(model);
    dietPlans = await _service.getTrainerDietPlans(model.trainerId);
    notifyListeners();
  }

  Future<void> deleteDietPlan(String dietId, String trainerId) async {
    await _service.deleteDietPlan(dietId);
    dietPlans = await _service.getTrainerDietPlans(trainerId);
    dietPlansCount = dietPlans.length;
    notifyListeners();
  }
}
