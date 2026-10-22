import 'package:flutter_test/flutter_test.dart';
import 'package:gymmanagement/core/utils/validators.dart';
import 'package:gymmanagement/models/user_model.dart';
import 'package:gymmanagement/models/fee_model.dart';
import 'package:gymmanagement/models/workout_plan_model.dart';
import 'package:gymmanagement/models/diet_plan_model.dart';
import 'package:gymmanagement/models/progress_model.dart';
import 'package:gymmanagement/models/cheat_day_model.dart';
import 'package:gymmanagement/models/message_model.dart';
import 'package:gymmanagement/services/firestore_service.dart';

void main() {
  group('Validators Unit Tests', () {
    test('email validator verifies correct email formats', () {
      expect(AppValidators.email(''), 'Email is required');
      expect(AppValidators.email('invalid-email'), 'Invalid email address');
      expect(AppValidators.email('member@gmail.com'), isNull);
    });

    test('password validator verifies minimum length', () {
      expect(AppValidators.password(''), 'Password is required');
      expect(
        AppValidators.password('123'),
        'Password must be at least 6 characters',
      );
      expect(AppValidators.password('Member@123'), isNull);
    });

    test('positiveNumber validator checks numbers', () {
      expect(AppValidators.positiveNumber('', 'Fee'), 'Fee is required');
      expect(
        AppValidators.positiveNumber('-5', 'Fee'),
        'Fee must be greater than 0',
      );
      expect(
        AppValidators.positiveNumber('0', 'Fee'),
        'Fee must be greater than 0',
      );
      expect(AppValidators.positiveNumber('1500', 'Fee'), isNull);
    });
  });

  group('Data Models Serialization Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        id: 'u123',
        name: 'Mohammed',
        email: 'mohammed@gmail.com',
        role: 'MEMBER',
        phone: '9876543210',
        fitnessGoal: 'Build muscle',
        status: 'ACTIVE',
      );

      final map = user.toMap();
      final fromMap = UserModel.fromMap(map, 'u123');

      expect(fromMap.id, 'u123');
      expect(fromMap.name, 'Mohammed');
      expect(fromMap.email, 'mohammed@gmail.com');
      expect(fromMap.isMember, isTrue);
      expect(fromMap.isActive, isTrue);
    });

    test('FeeModel serialization and payment calculation', () {
      final fee = FeeModel(
        id: 'f1',
        memberId: 'm1',
        memberName: 'Mohammed',
        memberEmail: 'mohammed@gmail.com',
        feeAmount: 1500,
        feeDate: '2026-09-09',
        feeMonth: 'SEPTEMBER',
        feeYear: 2026,
        paymentStatus: 'PAID',
      );

      final map = fee.toMap();
      final fromMap = FeeModel.fromMap(map, 'f1');

      expect(fromMap.feeAmount, 1500);
      expect(fromMap.isPaid, isTrue);
      expect(fromMap.feeMonth, 'SEPTEMBER');
    });

    test('WorkoutPlanModel and WorkoutExerciseModel serialization', () {
      final ex = WorkoutExerciseModel(
        id: 'ex1',
        workoutPlanId: 'p1',
        exerciseId: 'e3',
        exerciseName: 'Bench Press',
        workoutDay: 'MONDAY',
        sets: 4,
        reps: 10,
        durationMinutes: 15,
      );

      final map = ex.toMap();
      final fromMap = WorkoutExerciseModel.fromMap(map, 'ex1');

      expect(fromMap.exerciseName, 'Bench Press');
      expect(fromMap.workoutDay, 'MONDAY');
      expect(fromMap.sets, 4);
    });

    test('DietPlanModel and ProgressModel serialization', () {
      final diet = DietPlanModel(
        id: 'd1',
        trainerId: 't1',
        memberId: 'm1',
        dietDay: 'MONDAY',
        mealType: 'BREAKFAST',
        foodName: 'Oats with banana',
        calories: 350,
        protein: 20,
      );
      final dietMap = diet.toMap();
      expect(dietMap['calories'], 350);

      final progress = ProgressModel(
        id: 'pr1',
        memberId: 'm1',
        progressDate: '2026-09-09',
        weight: 72.5,
        bodyFat: 18.2,
        waistCm: 82,
        armsCm: 34,
      );
      final progMap = progress.toMap();
      expect(progMap['weight'], 72.5);

      final cheat = CheatDayModel(
        id: 'c1',
        memberId: 'm1',
        cheatDate: '2026-09-09',
        foodName: 'Pizza',
        quantity: '2 slices',
        calories: 600,
      );
      final cheatMap = cheat.toMap();
      expect(cheatMap['calories'], 600);
    });

    test('MessageModel serialization and roundtrip', () {
      final now = DateTime.now();
      final msg = MessageModel(
        id: 'msg123',
        senderId: 'trainer001',
        senderRole: 'TRAINER',
        receiverId: 'member001',
        receiverRole: 'MEMBER',
        message: 'Hello, great job on workouts today!',
        isRead: false,
        createdAt: now,
        updatedAt: now,
      );

      final map = msg.toMap();
      final fromMap = MessageModel.fromMap(map, 'msg123');

      expect(fromMap.id, 'msg123');
      expect(fromMap.senderId, 'trainer001');
      expect(fromMap.receiverId, 'member001');
      expect(fromMap.message, 'Hello, great job on workouts today!');
      expect(fromMap.senderRole, 'TRAINER');
      expect(fromMap.receiverRole, 'MEMBER');
      expect(fromMap.isRead, isFalse);
    });

    test('FirestoreService.getConversationId generates deterministic ID regardless of order', () {
      final id1 = FirestoreService.getConversationId('trainer001', 'member002');
      final id2 = FirestoreService.getConversationId('member002', 'trainer001');

      expect(id1, id2);
      expect(id1, 'member002_trainer001');
    });
  });
}
