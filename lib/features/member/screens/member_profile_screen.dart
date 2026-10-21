import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/member_profile_model.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  final _medicalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final member = Provider.of<MemberProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prof = member.profile;
    final user = auth.currentUser;

    _nameController.text = prof?.name ?? user?.name ?? '';
    _phoneController.text = prof?.phone ?? user?.phone ?? '';
    _ageController.text = (prof?.age != null && prof!.age > 0)
        ? prof.age.toString()
        : '24';
    _heightController.text = (prof?.height != null && prof!.height > 0)
        ? prof.height.toString()
        : '175';
    _weightController.text = (prof?.weight != null && prof!.weight > 0)
        ? prof.weight.toString()
        : '72.5';
    _goalController.text =
        prof?.fitnessGoal ??
        user?.fitnessGoal ??
        'Build muscle and improve overall fitness';
    _medicalController.text = prof?.medicalNotes ?? 'No known injuries';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final member = Provider.of<MemberProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) return;

    final updated = MemberProfileModel(
      id: user.id,
      memberId: user.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      height: double.tryParse(_heightController.text.trim()) ?? 0.0,
      weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
      fitnessGoal: _goalController.text.trim(),
      medicalNotes: _medicalController.text.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await member.updateProfile(updated);
      await auth.refreshUser();
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Physical & Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Keep your metrics up to date for your coach to adjust nutrition & training.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => AppValidators.requiredField(v, 'Name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _ageController,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.positiveNumber(v, 'Age'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.positiveNumber(v, 'Height'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.positiveNumber(v, 'Weight'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _goalController,
                  label: 'Fitness Goal',
                  hint: 'e.g. Build muscle and improve overall fitness',
                  prefixIcon: Icons.flag_outlined,
                  validator: (v) =>
                      AppValidators.requiredField(v, 'Fitness goal'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _medicalController,
                  label: 'Medical Notes & Restrictions',
                  hint: 'e.g. No known injuries / Lower back sensitivity',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
