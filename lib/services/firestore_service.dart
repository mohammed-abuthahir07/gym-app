import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/member_profile_model.dart';
import '../models/exercise_model.dart';
import '../models/challenge_model.dart';
import '../models/plan_model.dart';
import '../models/promotion_model.dart';
import '../models/workout_plan_model.dart';
import '../models/diet_plan_model.dart';
import '../models/class_schedule_model.dart';
import '../models/progress_model.dart';
import '../models/cheat_day_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/fee_model.dart';
import '../models/content_model.dart';
import '../models/contact_model.dart';
import '../core/utils/date_utils.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // PUBLIC & CONTACT
  // ==========================================
  Future<void> submitContact(ContactModel contact) async {
    await _db.collection('contacts').add(contact.toMap());
  }

  Future<List<PlanModel>> getPublicPlans() async {
    final snap = await _db
        .collection('plans')
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    return snap.docs.map((d) => PlanModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<PromotionModel>> getPublicPromotions() async {
    final snap = await _db
        .collection('promotions')
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    return snap.docs
        .map((d) => PromotionModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<List<ContentModel>> getPublicContent() async {
    final snap = await _db.collection('content').get();
    return snap.docs.map((d) => ContentModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> getPublicTrainers() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'TRAINER')
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  // ==========================================
  // MEMBER PROFILE
  // ==========================================
  Future<MemberProfileModel?> getMemberProfile(String memberId) async {
    final doc = await _db.collection('member_profiles').doc(memberId).get();
    if (!doc.exists) return null;
    return MemberProfileModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> saveMemberProfile(MemberProfileModel profile) async {
    await _db
        .collection('member_profiles')
        .doc(profile.memberId)
        .set(profile.toMap());
    // Also sync basic fields into users collection
    await _db.collection('users').doc(profile.memberId).update({
      'name': profile.name,
      'phone': profile.phone,
      'fitness_goal': profile.fitnessGoal,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // MEMBER PROGRESS TRACKING
  // ==========================================
  Future<List<ProgressModel>> getProgressList(String memberId) async {
    final snap = await _db
        .collection('progress')
        .where('member_id', isEqualTo: memberId)
        .get();
    final list = snap.docs
        .map((d) => ProgressModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.progressDate.compareTo(a.progressDate));
    return list;
  }

  Future<ProgressModel?> getProgress(String progressId) async {
    final doc = await _db.collection('progress').doc(progressId).get();
    if (!doc.exists) return null;
    return ProgressModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> addProgress(ProgressModel model) async {
    // Check if progress for this date already exists
    final snap = await _db
        .collection('progress')
        .where('member_id', isEqualTo: model.memberId)
        .where('progress_date', isEqualTo: model.progressDate)
        .get();
    if (snap.docs.isNotEmpty) {
      throw Exception('Progress already exists for this date');
    }
    await _db.collection('progress').add(model.toMap());
  }

  Future<void> updateProgress(ProgressModel model) async {
    await _db.collection('progress').doc(model.id).update(model.toMap());
  }

  Future<void> deleteProgress(String progressId) async {
    await _db.collection('progress').doc(progressId).delete();
  }

  // ==========================================
  // EXERCISES & CHALLENGES (MEMBER VIEW)
  // ==========================================
  Future<List<ExerciseModel>> getActiveExercises() async {
    final snap = await _db
        .collection('exercises')
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    return snap.docs.map((d) => ExerciseModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<ChallengeModel>> getActiveChallenges() async {
    final snap = await _db
        .collection('challenges')
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    return snap.docs
        .map((d) => ChallengeModel.fromMap(d.data(), d.id))
        .toList();
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================
  Future<List<NotificationModel>> getMemberNotifications(
    String memberId,
  ) async {
    final snap = await _db.collection('notifications').get();
    final all = snap.docs
        .map((d) => NotificationModel.fromMap(d.data(), d.id))
        .toList();
    // Filter for member: direct recipientId == memberId OR recipientRole == 'ALL_MEMBERS' or 'MEMBER'
    final filtered = all.where((n) {
      return n.recipientId == memberId ||
          n.recipientRole == 'ALL_MEMBERS' ||
          (n.recipientId == null && n.recipientRole == 'MEMBER');
    }).toList();
    filtered.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return filtered;
  }

  Future<void> markNotificationRead(String notifId) async {
    await _db.collection('notifications').doc(notifId).update({
      'is_read': 1,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // CLASS SCHEDULES
  // ==========================================
  Future<List<ClassScheduleModel>> getMemberClassSchedules(
    String? trainerId,
  ) async {
    if (trainerId == null || trainerId.isEmpty) return [];
    final snap = await _db
        .collection('class_schedules')
        .where('trainer_id', isEqualTo: trainerId)
        .get();
    final list = snap.docs
        .map((d) => ClassScheduleModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.classDate.compareTo(a.classDate));
    return list;
  }

  Future<ClassScheduleModel?> getClassSchedule(String scheduleId) async {
    final doc = await _db.collection('class_schedules').doc(scheduleId).get();
    if (!doc.exists) return null;
    return ClassScheduleModel.fromMap(doc.data()!, doc.id);
  }

  // ==========================================
  // WORKOUT PLANS & COMPLETIONS
  // ==========================================
  Future<List<WorkoutPlanModel>> getMemberWorkoutPlans(String memberId) async {
    final planSnap = await _db
        .collection('workout_plans')
        .where('member_id', isEqualTo: memberId)
        .get();

    final plans = <WorkoutPlanModel>[];
    for (final doc in planSnap.docs) {
      final exerciseSnap = await doc.reference.collection('exercises').get();
      final exercises = exerciseSnap.docs
          .map((e) => WorkoutExerciseModel.fromMap(e.data(), e.id))
          .toList();
      plans.add(
        WorkoutPlanModel.fromMap(doc.data(), doc.id, exercises: exercises),
      );
    }
    return plans;
  }

  Future<WorkoutPlanModel?> getWorkoutPlanDetails(String planId) async {
    final doc = await _db.collection('workout_plans').doc(planId).get();
    if (!doc.exists) return null;
    final exerciseSnap = await doc.reference.collection('exercises').get();
    final exercises = exerciseSnap.docs
        .map((e) => WorkoutExerciseModel.fromMap(e.data(), e.id))
        .toList();
    return WorkoutPlanModel.fromMap(doc.data()!, doc.id, exercises: exercises);
  }

  Future<void> completeWorkoutExercise({
    required String memberId,
    required String workoutPlanExerciseId,
    required String completedDate,
  }) async {
    // Check if already completed today
    final snap = await _db
        .collection('workout_completions')
        .where('member_id', isEqualTo: memberId)
        .where('workout_plan_exercise_id', isEqualTo: workoutPlanExerciseId)
        .where('completed_date', isEqualTo: completedDate)
        .get();

    if (snap.docs.isNotEmpty) {
      throw Exception('Workout already marked as completed for today');
    }

    final model = WorkoutCompletionModel(
      id: '',
      memberId: memberId,
      workoutPlanExerciseId: workoutPlanExerciseId,
      completedDate: completedDate,
      completedAt: DateTime.now(),
    );
    await _db.collection('workout_completions').add(model.toMap());
  }

  // ==========================================
  // DIET PLANS
  // ==========================================
  Future<List<DietPlanModel>> getMemberDietPlans(String memberId) async {
    final snap = await _db
        .collection('diet_plans')
        .where('member_id', isEqualTo: memberId)
        .get();
    return snap.docs.map((d) => DietPlanModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<DietPlanModel>> getMemberTodayDietPlans(
    String memberId,
    String day,
  ) async {
    final snap = await _db
        .collection('diet_plans')
        .where('member_id', isEqualTo: memberId)
        .where('diet_day', isEqualTo: day.toUpperCase())
        .get();
    return snap.docs.map((d) => DietPlanModel.fromMap(d.data(), d.id)).toList();
  }

  // ==========================================
  // CHEAT DAYS
  // ==========================================
  Future<void> addCheatDay(CheatDayModel model) async {
    await _db.collection('cheat_days').add(model.toMap());
  }

  Future<List<CheatDayModel>> getMemberCheatDays(String memberId) async {
    final snap = await _db
        .collection('cheat_days')
        .where('member_id', isEqualTo: memberId)
        .get();
    final list = snap.docs
        .map((d) => CheatDayModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.cheatDate.compareTo(a.cheatDate));
    return list;
  }

  Future<CheatDayModel?> getCheatDay(String cheatDayId) async {
    final doc = await _db.collection('cheat_days').doc(cheatDayId).get();
    if (!doc.exists) return null;
    return CheatDayModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateCheatDay(CheatDayModel model) async {
    await _db.collection('cheat_days').doc(model.id).update(model.toMap());
  }

  Future<void> deleteCheatDay(String cheatDayId) async {
    await _db.collection('cheat_days').doc(cheatDayId).delete();
  }

  // ==========================================
  // MESSAGES
  // ==========================================
  Stream<List<MessageModel>> getConversationStream(String userA, String userB) {
    return _db.collection('messages').snapshots().map((snap) {
      final messages = snap.docs
          .map((d) => MessageModel.fromMap(d.data(), d.id))
          .where(
            (m) =>
                (m.senderId == userA && m.receiverId == userB) ||
                (m.senderId == userB && m.receiverId == userA),
          )
          .toList();
      messages.sort(
        (a, b) => (a.createdAt ?? DateTime(2000)).compareTo(
          b.createdAt ?? DateTime(2000),
        ),
      );
      return messages;
    });
  }

  Future<void> sendMessage(MessageModel model) async {
    await _db.collection('messages').add(model.toMap());
  }

  Future<void> markMessageRead(String messageId) async {
    await _db.collection('messages').doc(messageId).update({
      'is_read': 1,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // FEES & PAYMENTS
  // ==========================================
  Future<List<FeeModel>> getMemberFees(String memberId) async {
    final snap = await _db
        .collection('fees')
        .where('member_id', isEqualTo: memberId)
        .get();
    final list = snap.docs
        .map((d) => FeeModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.feeDate.compareTo(a.feeDate));
    return list;
  }

  // ==========================================
  // CHECK-INS
  // ==========================================
  Future<void> recordCheckIn(String memberId) async {
    final today = AppDateUtils.todayDateString();
    final snap = await _db
        .collection('checkins')
        .where('member_id', isEqualTo: memberId)
        .where('checkin_date', isEqualTo: today)
        .get();
    if (snap.docs.isEmpty) {
      await _db.collection('checkins').add({
        'member_id': memberId,
        'checkin_date': today,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int> getMemberCheckInDays(String memberId) async {
    final snap = await _db
        .collection('checkins')
        .where('member_id', isEqualTo: memberId)
        .get();
    return snap.docs.length;
  }

  // ==========================================
  // TRAINER SPECIFIC METHODS
  // ==========================================
  Future<List<UserModel>> getAssignedMembers(String trainerId) async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'MEMBER')
        .where('trainer_id', isEqualTo: trainerId)
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> createClassSchedule(ClassScheduleModel model) async {
    await _db.collection('class_schedules').add(model.toMap());
  }

  Future<List<ClassScheduleModel>> getTrainerClassSchedules(
    String trainerId,
  ) async {
    final snap = await _db
        .collection('class_schedules')
        .where('trainer_id', isEqualTo: trainerId)
        .get();
    final list = snap.docs
        .map((d) => ClassScheduleModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.classDate.compareTo(a.classDate));
    return list;
  }

  Future<void> updateClassSchedule(ClassScheduleModel model) async {
    await _db.collection('class_schedules').doc(model.id).update(model.toMap());
  }

  Future<void> deleteClassSchedule(String scheduleId) async {
    await _db.collection('class_schedules').doc(scheduleId).delete();
  }

  Future<String> createWorkoutPlan(
    WorkoutPlanModel plan,
    WorkoutExerciseModel starterExercise,
  ) async {
    final planRef = await _db.collection('workout_plans').add(plan.toMap());
    final starterMap = starterExercise.toMap();
    starterMap['workout_plan_id'] = planRef.id;
    await planRef.collection('exercises').add(starterMap);
    return planRef.id;
  }

  Future<List<WorkoutPlanModel>> getTrainerWorkoutPlans(
    String trainerId,
  ) async {
    final snap = await _db
        .collection('workout_plans')
        .where('trainer_id', isEqualTo: trainerId)
        .get();
    final plans = <WorkoutPlanModel>[];
    for (final doc in snap.docs) {
      final exSnap = await doc.reference.collection('exercises').get();
      final exercises = exSnap.docs
          .map((e) => WorkoutExerciseModel.fromMap(e.data(), e.id))
          .toList();
      plans.add(
        WorkoutPlanModel.fromMap(doc.data(), doc.id, exercises: exercises),
      );
    }
    return plans;
  }

  Future<void> updateWorkoutPlanName(String planId, String newName) async {
    await _db.collection('workout_plans').doc(planId).update({
      'plan_name': newName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteWorkoutPlan(String planId) async {
    final exSnap = await _db
        .collection('workout_plans')
        .doc(planId)
        .collection('exercises')
        .get();
    for (final doc in exSnap.docs) {
      await doc.reference.delete();
    }
    await _db.collection('workout_plans').doc(planId).delete();
  }

  Future<void> addExerciseToWorkoutPlan(WorkoutExerciseModel exercise) async {
    await _db
        .collection('workout_plans')
        .doc(exercise.workoutPlanId)
        .collection('exercises')
        .add(exercise.toMap());
  }

  Future<void> updateWorkoutPlanExercise(WorkoutExerciseModel exercise) async {
    await _db
        .collection('workout_plans')
        .doc(exercise.workoutPlanId)
        .collection('exercises')
        .doc(exercise.id)
        .update(exercise.toMap());
  }

  Future<void> deleteWorkoutPlanExercise(
    String planId,
    String exerciseId,
  ) async {
    await _db
        .collection('workout_plans')
        .doc(planId)
        .collection('exercises')
        .doc(exerciseId)
        .delete();
  }

  Future<void> createDietPlan(DietPlanModel model) async {
    await _db.collection('diet_plans').add(model.toMap());
  }

  Future<List<DietPlanModel>> getTrainerDietPlans(String trainerId) async {
    final snap = await _db
        .collection('diet_plans')
        .where('trainer_id', isEqualTo: trainerId)
        .get();
    return snap.docs.map((d) => DietPlanModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> updateDietPlan(DietPlanModel model) async {
    await _db.collection('diet_plans').doc(model.id).update(model.toMap());
  }

  Future<void> deleteDietPlan(String dietId) async {
    await _db.collection('diet_plans').doc(dietId).delete();
  }

  // ==========================================
  // ADMIN SPECIFIC METHODS
  // ==========================================
  Future<List<UserModel>> getAllTrainers() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'TRAINER')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> deactivateTrainer(String trainerId) async {
    await _db.collection('users').doc(trainerId).update({
      'status': 'INACTIVE',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<UserModel>> getAllMembers() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'MEMBER')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> deactivateMember(String memberId) async {
    await _db.collection('users').doc(memberId).update({
      'status': 'INACTIVE',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> assignTrainerToMember({
    required String memberId,
    required String trainerId,
    required String trainerName,
    required String trainerEmail,
  }) async {
    await _db.collection('users').doc(memberId).update({
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'trainer_email': trainerEmail,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeTrainerFromMember(String memberId) async {
    await _db.collection('users').doc(memberId).update({
      'trainer_id': null,
      'trainer_name': null,
      'trainer_email': null,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Plan Management
  Future<void> createPlan(PlanModel model) async {
    await _db.collection('plans').add(model.toMap());
  }

  Future<List<PlanModel>> getAllPlans() async {
    final snap = await _db.collection('plans').get();
    return snap.docs.map((d) => PlanModel.fromMap(d.data(), d.id)).toList();
  }

  // Promotion Management
  Future<void> createPromotion(PromotionModel model) async {
    await _db.collection('promotions').add(model.toMap());
  }

  Future<List<PromotionModel>> getAllPromotions() async {
    final snap = await _db.collection('promotions').get();
    return snap.docs
        .map((d) => PromotionModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updatePromotion(PromotionModel model) async {
    await _db.collection('promotions').doc(model.id).update(model.toMap());
  }

  Future<void> deletePromotion(String promotionId) async {
    await _db.collection('promotions').doc(promotionId).delete();
  }

  // Challenge Management
  Future<void> createChallenge(ChallengeModel model) async {
    await _db.collection('challenges').add(model.toMap());
  }

  Future<List<ChallengeModel>> getAllChallenges() async {
    final snap = await _db.collection('challenges').get();
    return snap.docs
        .map((d) => ChallengeModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> updateChallenge(ChallengeModel model) async {
    await _db.collection('challenges').doc(model.id).update(model.toMap());
  }

  Future<void> deleteChallenge(String challengeId) async {
    await _db.collection('challenges').doc(challengeId).delete();
  }

  // Exercise Management
  Future<void> createExercise(ExerciseModel model) async {
    await _db.collection('exercises').add(model.toMap());
  }

  Future<List<ExerciseModel>> getAllExercises() async {
    final snap = await _db.collection('exercises').get();
    return snap.docs.map((d) => ExerciseModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> updateExercise(ExerciseModel model) async {
    await _db.collection('exercises').doc(model.id).update(model.toMap());
  }

  Future<void> deleteExercise(String exerciseId) async {
    await _db.collection('exercises').doc(exerciseId).delete();
  }

  // Notifications
  Future<void> broadcastNotification({
    required String title,
    required String message,
    required String
    targetRole, // 'ALL_MEMBERS', 'ALL_TRAINERS', 'MEMBER', 'TRAINER'
    String? individualRecipientId,
  }) async {
    final model = NotificationModel(
      id: '',
      recipientId: individualRecipientId,
      recipientRole: targetRole,
      title: title,
      message: message,
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.collection('notifications').add(model.toMap());
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final snap = await _db.collection('notifications').get();
    final list = snap.docs
        .map((d) => NotificationModel.fromMap(d.data(), d.id))
        .toList();
    list.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return list;
  }

  // Contacts
  Future<List<ContactModel>> getAllContacts() async {
    final snap = await _db.collection('contacts').get();
    final list = snap.docs
        .map((d) => ContactModel.fromMap(d.data(), d.id))
        .toList();
    list.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return list;
  }

  Future<void> markContactRead(String contactId) async {
    await _db.collection('contacts').doc(contactId).update({
      'status': 'READ',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteContact(String contactId) async {
    await _db.collection('contacts').doc(contactId).delete();
  }

  // Content
  Future<void> createContent(ContentModel model) async {
    await _db.collection('content').add(model.toMap());
  }

  Future<List<ContentModel>> getAllContent() async {
    final snap = await _db.collection('content').get();
    return snap.docs.map((d) => ContentModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> updateContent(ContentModel model) async {
    await _db.collection('content').doc(model.id).update(model.toMap());
  }

  Future<void> deleteContent(String contentId) async {
    await _db.collection('content').doc(contentId).delete();
  }

  // Fee Management
  Future<void> createFee(FeeModel model) async {
    await _db.collection('fees').add(model.toMap());
  }

  Future<List<FeeModel>> getAllFees() async {
    final snap = await _db.collection('fees').get();
    final list = snap.docs
        .map((d) => FeeModel.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.feeDate.compareTo(a.feeDate));
    return list;
  }

  Future<void> updateFee(FeeModel model) async {
    await _db.collection('fees').doc(model.id).update(model.toMap());
  }

  Future<void> deleteFee(String feeId) async {
    await _db.collection('fees').doc(feeId).delete();
  }
}
