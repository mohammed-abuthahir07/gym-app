import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/plan_model.dart';
import '../models/promotion_model.dart';
import '../models/challenge_model.dart';
import '../models/exercise_model.dart';
import '../models/content_model.dart';
import '../models/contact_model.dart';
import '../models/fee_model.dart';
import '../models/notification_model.dart';
import '../core/utils/date_utils.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<UserModel> trainers = [];
  List<UserModel> members = [];
  List<PlanModel> plans = [];
  List<PromotionModel> promotions = [];
  List<ChallengeModel> challenges = [];
  List<ExerciseModel> exercises = [];
  List<ContentModel> contents = [];
  List<ContactModel> contacts = [];
  List<FeeModel> fees = [];
  List<NotificationModel> notifications = [];

  // Metrics
  double currentMonthRevenue = 0.0;
  double currentYearRevenue = 0.0;
  double totalRevenue = 0.0;
  int currentMonthCheckIns = 0;
  int currentYearCheckIns = 0;
  int currentMonthUnpaidCount = 0;

  Future<void> loadAllData() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      trainers = await _service.getAllTrainers();
      members = await _service.getAllMembers();
      plans = await _service.getAllPlans();
      promotions = await _service.getAllPromotions();
      challenges = await _service.getAllChallenges();
      exercises = await _service.getAllExercises();
      contents = await _service.getAllContent();
      contacts = await _service.getAllContacts();
      fees = await _service.getAllFees();
      notifications = await _service.getAllNotifications();

      _calculateRevenueAndReports();
    } catch (e) {
      _errorMessage = 'Unable to load administration data. Please check your network and retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateRevenueAndReports() {
    final currentMonth = AppDateUtils.currentMonthName();
    final currentYear = AppDateUtils.currentYear();

    currentMonthRevenue = 0.0;
    currentYearRevenue = 0.0;
    totalRevenue = 0.0;
    currentMonthUnpaidCount = 0;

    for (final f in fees) {
      if (f.isPaid) {
        totalRevenue += f.feeAmount;
        if (f.feeYear == currentYear) {
          currentYearRevenue += f.feeAmount;
          if (f.feeMonth == currentMonth) {
            currentMonthRevenue += f.feeAmount;
          }
        }
      } else {
        if (f.feeYear == currentYear && f.feeMonth == currentMonth) {
          currentMonthUnpaidCount++;
        }
      }
    }
  }

  // Trainers
  Future<void> createTrainer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final authService = AuthService();
    await authService.createTrainer(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    trainers = await _service.getAllTrainers();
    notifyListeners();
  }

  Future<void> deactivateTrainer(String trainerId) async {
    await _service.deactivateTrainer(trainerId);
    trainers = await _service.getAllTrainers();
    notifyListeners();
  }

  // Members
  Future<void> deactivateMember(String memberId) async {
    await _service.deactivateMember(memberId);
    members = await _service.getAllMembers();
    notifyListeners();
  }

  Future<void> assignTrainerToMember({
    required String memberId,
    required String trainerId,
    required String trainerName,
    required String trainerEmail,
  }) async {
    await _service.assignTrainerToMember(
      memberId: memberId,
      trainerId: trainerId,
      trainerName: trainerName,
      trainerEmail: trainerEmail,
    );
    members = await _service.getAllMembers();
    notifyListeners();
  }

  Future<void> removeTrainerFromMember(String memberId) async {
    await _service.removeTrainerFromMember(memberId);
    members = await _service.getAllMembers();
    notifyListeners();
  }

  // Plans
  Future<void> addPlan(PlanModel model) async {
    await _service.createPlan(model);
    plans = await _service.getAllPlans();
    notifyListeners();
  }

  // Promotions
  Future<void> addPromotion(PromotionModel model) async {
    await _service.createPromotion(model);
    promotions = await _service.getAllPromotions();
    notifyListeners();
  }

  Future<void> updatePromotion(PromotionModel model) async {
    await _service.updatePromotion(model);
    promotions = await _service.getAllPromotions();
    notifyListeners();
  }

  Future<void> deletePromotion(String id) async {
    await _service.deletePromotion(id);
    promotions = await _service.getAllPromotions();
    notifyListeners();
  }

  // Challenges
  Future<void> addChallenge(ChallengeModel model) async {
    await _service.createChallenge(model);
    challenges = await _service.getAllChallenges();
    notifyListeners();
  }

  Future<void> updateChallenge(ChallengeModel model) async {
    await _service.updateChallenge(model);
    challenges = await _service.getAllChallenges();
    notifyListeners();
  }

  Future<void> deleteChallenge(String id) async {
    await _service.deleteChallenge(id);
    challenges = await _service.getAllChallenges();
    notifyListeners();
  }

  // Exercises
  Future<void> addExercise(ExerciseModel model) async {
    await _service.createExercise(model);
    exercises = await _service.getAllExercises();
    notifyListeners();
  }

  Future<void> updateExercise(ExerciseModel model) async {
    await _service.updateExercise(model);
    exercises = await _service.getAllExercises();
    notifyListeners();
  }

  Future<void> deleteExercise(String id) async {
    await _service.deleteExercise(id);
    exercises = await _service.getAllExercises();
    notifyListeners();
  }

  // Notifications
  Future<void> broadcastNotification({
    required String title,
    required String message,
    required String targetRole,
    String? individualRecipientId,
  }) async {
    await _service.broadcastNotification(
      title: title,
      message: message,
      targetRole: targetRole,
      individualRecipientId: individualRecipientId,
    );
    notifications = await _service.getAllNotifications();
    notifyListeners();
  }

  // Fees
  Future<void> addFee(FeeModel model) async {
    await _service.createFee(model);
    fees = await _service.getAllFees();
    _calculateRevenueAndReports();
    notifyListeners();
  }

  Future<void> updateFee(FeeModel model) async {
    await _service.updateFee(model);
    fees = await _service.getAllFees();
    _calculateRevenueAndReports();
    notifyListeners();
  }

  Future<void> deleteFee(String id) async {
    await _service.deleteFee(id);
    fees = await _service.getAllFees();
    _calculateRevenueAndReports();
    notifyListeners();
  }

  // Content
  Future<void> addContent(ContentModel model) async {
    await _service.createContent(model);
    contents = await _service.getAllContent();
    notifyListeners();
  }

  Future<void> updateContent(ContentModel model) async {
    await _service.updateContent(model);
    contents = await _service.getAllContent();
    notifyListeners();
  }

  Future<void> deleteContent(String id) async {
    await _service.deleteContent(id);
    contents = await _service.getAllContent();
    notifyListeners();
  }

  // Contacts
  Future<void> markContactRead(String id) async {
    await _service.markContactRead(id);
    contacts = await _service.getAllContacts();
    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    await _service.deleteContact(id);
    contacts = await _service.getAllContacts();
    notifyListeners();
  }
}
