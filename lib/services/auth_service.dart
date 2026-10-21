import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/member_profile_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Register Member (Default role is always MEMBER for public registration)
  Future<UserModel> registerMember({
    required String name,
    required String email,
    required String phone,
    required String fitnessGoal,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user!.uid;
    final now = DateTime.now();

    final userModel = UserModel(
      id: uid,
      name: name.trim(),
      email: email.trim(),
      role: 'MEMBER',
      phone: phone.trim(),
      fitnessGoal: fitnessGoal.trim(),
      status: 'ACTIVE',
      createdAt: now,
      updatedAt: now,
    );

    // Save to users collection
    await _firestore.collection('users').doc(uid).set(userModel.toMap());

    // Initialize member profile
    final profile = MemberProfileModel(
      id: uid,
      memberId: uid,
      name: name.trim(),
      phone: phone.trim(),
      age: 0,
      height: 0,
      weight: 0,
      fitnessGoal: fitnessGoal.trim(),
      medicalNotes: '',
      createdAt: now,
      updatedAt: now,
    );
    await _firestore
        .collection('member_profiles')
        .doc(uid)
        .set(profile.toMap());

    return userModel;
  }

  // Admin creates a Trainer account with credentials
  Future<UserModel> createTrainer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final now = DateTime.now();

    // 1. Check if a user with this email already exists in Firestore
    final existingSnap = await _firestore
        .collection('users')
        .where('email', isEqualTo: cleanEmail)
        .get();

    if (existingSnap.docs.isNotEmpty) {
      final doc = existingSnap.docs.first;
      // Re-activate or update trainer profile
      await doc.reference.update({
        'name': name.trim(),
        'phone': phone.trim(),
        'role': 'TRAINER',
        'status': 'ACTIVE',
        'updated_at': now.toIso8601String(),
      });
      return UserModel.fromMap({
        ...doc.data(),
        'name': name.trim(),
        'phone': phone.trim(),
        'role': 'TRAINER',
        'status': 'ACTIVE',
      }, doc.id);
    }

    // 2. If not in Firestore, attempt creation or linkage with Firebase Auth
    String? uid;
    try {
      final appName = 'TrainerAuth_${DateTime.now().millisecondsSinceEpoch}';
      final tempApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );
      try {
        try {
          final cred = await FirebaseAuth.instanceFor(app: tempApp)
              .createUserWithEmailAndPassword(
                email: cleanEmail,
                password: password,
              );
          uid = cred.user?.uid;
        } on FirebaseAuthException catch (authErr) {
          if (authErr.code == 'email-already-in-use') {
            // Already in Firebase Auth: try signing in to retrieve existing Auth UID
            try {
              final cred = await FirebaseAuth.instanceFor(app: tempApp)
                  .signInWithEmailAndPassword(
                    email: cleanEmail,
                    password: password,
                  );
              uid = cred.user?.uid;
            } catch (_) {
              // Password may differ, will fallback to a new document id
            }
          } else {
            rethrow;
          }
        }
      } finally {
        await tempApp.delete();
      }
    } catch (_) {}

    uid ??= _firestore.collection('users').doc().id;

    final trainerModel = UserModel(
      id: uid,
      name: name.trim(),
      email: cleanEmail,
      role: 'TRAINER',
      phone: phone.trim(),
      status: 'ACTIVE',
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('users').doc(uid).set(trainerModel.toMap());
    return trainerModel;
  }

  // Sign In with role check and inactive account guard
  Future<UserModel> signIn({
    required String email,
    required String password,
    String? expectedRole,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final uid = userCredential.user!.uid;
    var doc = await _firestore.collection('users').doc(uid).get();

    // Auto-link if document exists by email
    if (!doc.exists) {
      final emailSnap = await _firestore
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .get();
      if (emailSnap.docs.isNotEmpty) {
        final existingDoc = emailSnap.docs.first;
        final mergedData = {
          ...existingDoc.data(),
          'id': uid,
          'updated_at': DateTime.now().toIso8601String(),
        };
        await _firestore.collection('users').doc(uid).set(mergedData);
        doc = await _firestore.collection('users').doc(uid).get();
      }
    }

    // Auto-provision profile if document still does not exist
    if (!doc.exists) {
      final now = DateTime.now();
      final defaultRole = (expectedRole ?? 'MEMBER').toUpperCase();
      final newUserData = {
        'id': uid,
        'name': cleanEmail.split('@').first,
        'email': cleanEmail,
        'role': defaultRole,
        'phone': '',
        'status': 'ACTIVE',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      await _firestore.collection('users').doc(uid).set(newUserData);
      doc = await _firestore.collection('users').doc(uid).get();
    }

    final user = UserModel.fromMap(doc.data()!, uid);

    if (!user.isActive) {
      await _auth.signOut();
      throw Exception(
        '${user.role} account is inactive. Please contact administration.',
      );
    }

    if (expectedRole != null && user.role != expectedRole.toUpperCase()) {
      await _auth.signOut();
      throw Exception(
        'Access denied. This login portal requires $expectedRole credentials.',
      );
    }

    return user;
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, user.uid);
  }

  // Password reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
