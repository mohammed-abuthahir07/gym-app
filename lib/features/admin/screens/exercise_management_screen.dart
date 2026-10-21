import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/exercise_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ExerciseManagementScreen extends StatefulWidget {
  const ExerciseManagementScreen({super.key});

  @override
  State<ExerciseManagementScreen> createState() =>
      _ExerciseManagementScreenState();
}

class _ExerciseManagementScreenState extends State<ExerciseManagementScreen> {
  void _showAddExerciseDialog() {
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController();
    final equipCtrl = TextEditingController();
    final instrCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final vidCtrl = TextEditingController();
    String difficulty = 'INTERMEDIATE';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Exercise to Library'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Exercise Name',
                    hint: 'e.g. Bench Press',
                    validator: (v) => AppValidators.requiredField(v, 'Name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: muscleCtrl,
                    label: 'Target Muscle Group',
                    hint: 'e.g. Chest, Back, Legs, Shoulders',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Muscle Group'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: equipCtrl,
                    label: 'Equipment Needed',
                    hint: 'e.g. Barbell, Dumbbell, Cable',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Equipment'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: difficulty,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                    ),
                    items: ['BEGINNER', 'INTERMEDIATE', 'DIFFICULT'].map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => difficulty = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: instrCtrl,
                    label: 'Step-by-step Instructions',
                    maxLines: 3,
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Instructions'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: imgCtrl,
                    label: 'Image URL (optional)',
                    hint: 'https://...',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: vidCtrl,
                    label: 'Video Guide URL (optional)',
                    hint: 'https://...',
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
              text: 'Save Exercise',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final ex = ExerciseModel(
                    id: '',
                    name: nameCtrl.text.trim(),
                    muscleGroup: muscleCtrl.text.trim(),
                    equipment: equipCtrl.text.trim(),
                    instructions: instrCtrl.text.trim(),
                    imageUrl: imgCtrl.text.trim(),
                    videoUrl: vidCtrl.text.trim(),
                    difficulty: difficulty,
                    status: 'ACTIVE',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).addExercise(ex);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exercise saved to library!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
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
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddExerciseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
      body: admin.exercises.isEmpty
          ? const EmptyState(
              title: 'Empty Exercise Catalog',
              message: 'Add exercises for coaches and trainers to build workout plans.',
              icon: Icons.fitness_center,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.exercises.length,
              itemBuilder: (ctx, idx) {
                final ex = admin.exercises[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ex.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ex.difficulty == 'BEGINNER'
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : ex.difficulty == 'INTERMEDIATE'
                                    ? AppColors.info.withValues(alpha: 0.2)
                                    : AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ex.difficulty,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ex.difficulty == 'BEGINNER'
                                      ? AppColors.success
                                      : ex.difficulty == 'INTERMEDIATE'
                                      ? AppColors.info
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Target: ${ex.muscleGroup} • Equipment: ${ex.equipment}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ex.instructions,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
