import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../models/plan_model.dart';
import '../models/promotion_model.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../models/contact_model.dart';

class PublicProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PlanModel> plans = [];
  List<PromotionModel> promotions = [];
  List<ContentModel> contents = [];
  List<UserModel> trainers = [];

  Future<void> loadPublicData() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      try {
        plans = await _service.getPublicPlans();
      } catch (e) {
        debugPrint('Error loading public plans: $e');
      }
      try {
        promotions = await _service.getPublicPromotions();
      } catch (e) {
        debugPrint('Error loading public promotions: $e');
      }
      try {
        contents = await _service.getPublicContent();
      } catch (e) {
        debugPrint('Error loading public content: $e');
      }
      // trainers are served from static data in PublicTrainersScreen,
      // so we skip the Firestore query here to avoid PERMISSION_DENIED
      // for unauthenticated (signed-out) public visitors.
    } catch (e) {
      _errorMessage =
          'Unable to load highlights. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitContactEnquiry({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = ContactModel(
        id: '',
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        message: message.trim(),
        status: 'NEW',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _service.submitContact(model);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
