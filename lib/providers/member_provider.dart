import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/firestore_service.dart';
import '../models/member_profile_model.dart';
import '../models/progress_model.dart';
import '../models/workout_plan_model.dart';
import '../models/diet_plan_model.dart';
import '../models/class_schedule_model.dart';
import '../models/cheat_day_model.dart';
import '../models/notification_model.dart';
import '../models/fee_model.dart';
import '../models/exercise_model.dart';
import '../models/challenge_model.dart';
import '../core/utils/date_utils.dart';

class MemberProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MemberProfileModel? profile;
  List<ProgressModel> progressList = [];
  List<WorkoutPlanModel> workoutPlans = [];
  List<DietPlanModel> dietPlans = [];
  List<DietPlanModel> todayDietPlans = [];
  List<ClassScheduleModel> schedules = [];
  List<CheatDayModel> cheatDays = [];
  List<NotificationModel> notifications = [];
  List<FeeModel> fees = [];
  List<ExerciseModel> exercises = [];
  List<ChallengeModel> challenges = [];

  // Dashboard & Analytics
  int checkInDays = 0;
  int currentMonthCheatCount = 0;
  int workoutPlansCount = 0;
  int notificationCount = 0;
  ProgressModel? previousMonthProgress;
  ProgressModel? currentMonthProgress;
  List<WorkoutExerciseModel> todayWorkouts = [];
  List<WorkoutExerciseModel> tomorrowWorkouts = [];
  Set<String> todayCompletedExerciseIds = {};
  String currentMonthPaymentStatus = 'UNPAID';

  Future<void> loadMemberData(String memberId, String? trainerId) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Gym Check-In Days & Today's Completed Exercises
      try {
        final today = AppDateUtils.todayDateString();
        todayCompletedExerciseIds = await _service
            .getMemberCompletedExerciseIdsForDate(memberId, today);
        checkInDays = await _service.getMemberCheckInDays(memberId);
      } catch (e) {
        debugPrint('Error loading check-in and completed workouts: $e');
      }

      // 2. Profile
      try {
        profile = await _service.getMemberProfile(memberId);
      } catch (e) {
        debugPrint('Error loading member profile: $e');
      }

      // 3. Progress
      try {
        progressList = await _service.getProgressList(memberId);
        _calculateProgressAnalytics();
      } catch (e) {
        debugPrint('Error loading member progress: $e');
      }

      // 4. Workout Plans
      try {
        workoutPlans = await _service.getMemberWorkoutPlans(memberId);
        workoutPlansCount = workoutPlans.length;
        _calculateDailyWorkouts();
      } catch (e) {
        debugPrint('Error loading member workout plans: $e');
      }

      // 5. Diet Plans
      try {
        dietPlans = await _service.getMemberDietPlans(memberId);
        final currentDay = AppDateUtils.currentDayName();
        todayDietPlans = await _service.getMemberTodayDietPlans(
          memberId,
          currentDay,
        );
      } catch (e) {
        debugPrint('Error loading member diet plans: $e');
      }

      // 6. Cheat Days
      try {
        cheatDays = await _service.getMemberCheatDays(memberId);
        _calculateCheatCount();
      } catch (e) {
        debugPrint('Error loading member cheat days: $e');
      }

      // 7. Class Schedules (from trainer)
      try {
        schedules = await _service.getMemberClassSchedules(trainerId);
      } catch (e) {
        debugPrint('Error loading member class schedules: $e');
      }

      // 8. Notifications
      try {
        notifications = await _service.getMemberNotifications(memberId);
        notificationCount = notifications.where((n) => !n.isRead).length;
      } catch (e) {
        debugPrint('Error loading member notifications: $e');
      }

      // 9. Fees
      try {
        fees = await _service.getMemberFees(memberId);
        _calculatePaymentStatus();
      } catch (e) {
        debugPrint('Error loading member fees: $e');
      }

      // 10. Exercises & Challenges
      try {
        exercises = await _service.getActiveExercises();
      } catch (e) {
        debugPrint('Error loading active exercises: $e');
      }
      try {
        challenges = await _service.getActiveChallenges();
      } catch (e) {
        debugPrint('Error loading active challenges: $e');
      }
    } catch (e) {
      _errorMessage = 'Unable to load fitness metrics. Please check your connection and retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateDailyWorkouts() {
    final now = DateTime.now();
    final todayName = AppDateUtils.currentDayName();
    final tomorrowName = DateFormat('EEEE')
        .format(now.add(const Duration(days: 1)))
        .toUpperCase();

    todayWorkouts = [];
    tomorrowWorkouts = [];

    for (final plan in workoutPlans) {
      for (final ex in plan.exercises) {
        if (ex.workoutDay == todayName) {
          todayWorkouts.add(ex);
        }
        if (ex.workoutDay == tomorrowName) {
          tomorrowWorkouts.add(ex);
        }
      }
    }
  }

  void _calculateProgressAnalytics() {
    if (progressList.isEmpty) return;

    final now = DateTime.now();
    final currentYearMonth = DateFormat('yyyy-MM').format(now);
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final prevYearMonth = DateFormat('yyyy-MM').format(prevMonthDate);

    currentMonthProgress = progressList.firstWhere(
      (p) => p.progressDate.startsWith(currentYearMonth),
      orElse: () => progressList.first,
    );

    try {
      previousMonthProgress = progressList.firstWhere(
        (p) => p.progressDate.startsWith(prevYearMonth),
      );
    } catch (_) {
      previousMonthProgress = null;
    }
  }

  void _calculateCheatCount() {
    final now = DateTime.now();
    final currentYearMonth = DateFormat('yyyy-MM').format(now);
    currentMonthCheatCount = cheatDays
        .where((c) => c.cheatDate.startsWith(currentYearMonth))
        .length;
  }

  void _calculatePaymentStatus() {
    final currentMonth = AppDateUtils.currentMonthName().trim().toUpperCase();
    final currentYear = AppDateUtils.currentYear();
    final now = DateTime.now();
    final currentYearMonth =
        "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final currentFee = fees.where((f) {
      final monthMatches =
          f.feeMonth.trim().toUpperCase() == currentMonth &&
          f.feeYear == currentYear;
      final dateMatches = f.feeDate.trim().startsWith(currentYearMonth);
      return monthMatches || dateMatches;
    }).toList();

    if (currentFee.isNotEmpty && currentFee.any((f) => f.isPaid)) {
      currentMonthPaymentStatus = 'PAID';
    } else {
      currentMonthPaymentStatus = 'UNPAID';
    }
  }

  // Profile
  Future<void> updateProfile(MemberProfileModel updatedProfile) async {
    await _service.saveMemberProfile(updatedProfile);
    profile = updatedProfile;
    notifyListeners();
  }

  // Progress
  Future<void> addProgress(ProgressModel model) async {
    await _service.addProgress(model);
    progressList = await _service.getProgressList(model.memberId);
    _calculateProgressAnalytics();
    notifyListeners();
  }

  Future<void> updateProgress(ProgressModel model) async {
    await _service.updateProgress(model);
    progressList = await _service.getProgressList(model.memberId);
    _calculateProgressAnalytics();
    notifyListeners();
  }

  Future<void> deleteProgress(String progressId, String memberId) async {
    await _service.deleteProgress(progressId);
    progressList = await _service.getProgressList(memberId);
    _calculateProgressAnalytics();
    notifyListeners();
  }

  // Complete Workout Exercise
  Future<void> completeWorkoutExercise({
    required String memberId,
    required String workoutPlanExerciseId,
  }) async {
    final today = AppDateUtils.todayDateString();
    await _service.completeWorkoutExercise(
      memberId: memberId,
      workoutPlanExerciseId: workoutPlanExerciseId,
      completedDate: today,
    );
    todayCompletedExerciseIds.add(workoutPlanExerciseId);
    try {
      checkInDays = await _service.getMemberCheckInDays(memberId);
    } catch (e) {
      debugPrint('Error updating check-in days after workout completion: $e');
    }
    notifyListeners();
  }

  // Cheat Days
  Future<void> addCheatDay(CheatDayModel model) async {
    await _service.addCheatDay(model);
    cheatDays = await _service.getMemberCheatDays(model.memberId);
    _calculateCheatCount();
    notifyListeners();
  }

  Future<void> updateCheatDay(CheatDayModel model) async {
    await _service.updateCheatDay(model);
    cheatDays = await _service.getMemberCheatDays(model.memberId);
    _calculateCheatCount();
    notifyListeners();
  }

  Future<void> deleteCheatDay(String cheatDayId, String memberId) async {
    await _service.deleteCheatDay(cheatDayId);
    cheatDays = await _service.getMemberCheatDays(memberId);
    _calculateCheatCount();
    notifyListeners();
  }

  // Notifications
  Future<void> markNotificationRead(String notifId, String memberId) async {
    await _service.markNotificationRead(notifId);
    notifications = await _service.getMemberNotifications(memberId);
    notificationCount = notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }
}
