import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/progress_model.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class MemberProgressScreen extends StatefulWidget {
  const MemberProgressScreen({super.key});

  @override
  State<MemberProgressScreen> createState() => _MemberProgressScreenState();
}

class _MemberProgressScreenState extends State<MemberProgressScreen> {
  void _showAddProgressDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final member = Provider.of<MemberProvider>(context, listen: false);
    if (auth.currentUser == null) return;

    final dateCtrl = TextEditingController(
      text: AppDateUtils.todayDateString(),
    );
    final weightCtrl = TextEditingController(text: '72.5');
    final fatCtrl = TextEditingController(text: '18.2');
    final waistCtrl = TextEditingController(text: '82');
    final armsCtrl = TextEditingController(text: '34');
    final notesCtrl = TextEditingController(text: 'Feeling stronger this week');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Physical Progress'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: dateCtrl,
                    label: 'Date (YYYY-MM-DD)',
                    validator: (v) => AppValidators.requiredField(v, 'Date'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: weightCtrl,
                          label: 'Weight (kg)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Weight'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: fatCtrl,
                          label: 'Body Fat (%)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Body fat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: waistCtrl,
                          label: 'Waist (cm)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Waist'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: armsCtrl,
                          label: 'Arms (cm)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Arms'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesCtrl,
                    label: 'Personal Notes',
                    hint: 'e.g. Energy levels, strength improvements',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Save Progress',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final now = DateTime.now();
                  final p = ProgressModel(
                    id: '',
                    memberId: auth.currentUser!.id,
                    progressDate: dateCtrl.text.trim(),
                    weight: double.parse(weightCtrl.text.trim()),
                    bodyFat: double.parse(fatCtrl.text.trim()),
                    waistCm: double.parse(waistCtrl.text.trim()),
                    armsCm: double.parse(armsCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );
                  await member.addProgress(p);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progress logged successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Body Measurements & Progress')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddProgressDialog,
        icon: const Icon(Icons.add),
        label: const Text('Log Check-in'),
      ),
      body: member.progressList.isEmpty
          ? const EmptyState(
              title: 'No Measurements Logged',
              message: 'Record your weight, body fat %, waist, and arm circumference to track changes.',
              icon: Icons.show_chart,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: member.progressList.length,
              itemBuilder: (ctx, idx) {
                final p = member.progressList[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.progressDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                if (auth.currentUser != null) {
                                  member.deleteProgress(
                                    p.id,
                                    auth.currentUser!.id,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetricChip(
                              'Weight',
                              '${p.weight} kg',
                              AppColors.primary,
                            ),
                            _buildMetricChip(
                              'Body Fat',
                              '${p.bodyFat}%',
                              AppColors.accent,
                            ),
                            _buildMetricChip(
                              'Waist',
                              '${p.waistCm} cm',
                              AppColors.info,
                            ),
                            _buildMetricChip(
                              'Arms',
                              '${p.armsCm} cm',
                              AppColors.success,
                            ),
                          ],
                        ),
                        if (p.notes.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Notes: ${p.notes}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
