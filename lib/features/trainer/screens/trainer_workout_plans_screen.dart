import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/workout_plan_model.dart';
import '../../../models/exercise_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class TrainerWorkoutPlansScreen extends StatefulWidget {
  const TrainerWorkoutPlansScreen({super.key});

  @override
  State<TrainerWorkoutPlansScreen> createState() =>
      _TrainerWorkoutPlansScreenState();
}

class _TrainerWorkoutPlansScreenState extends State<TrainerWorkoutPlansScreen> {
  final List<String> _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  void _showCreatePlanDialog() {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (trainer.assignedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have no assigned members to create plans for.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (trainer.availableExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No active exercises available in library. Please contact Admin.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    UserModel selectedMember = trainer.assignedMembers.first;
    ExerciseModel selectedExercise = trainer.availableExercises.first;
    final planNameCtrl = TextEditingController(text: 'Push Pull Legs');
    String workoutDay = 'MONDAY';
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '10');
    final durationCtrl = TextEditingController(text: '15');
    final notesCtrl = TextEditingController(text: 'Keep elbows at 45 degrees');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create & Assign Workout Plan'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UserModel>(
                    value: selectedMember,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Assign to Member',
                    ),
                    items: trainer.assignedMembers.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedMember = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: planNameCtrl,
                    label: 'Plan Name',
                    hint: 'e.g. Upper Body Strength',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Plan name'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Starter Exercise Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExerciseModel>(
                    value: selectedExercise,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Exercise'),
                    items: trainer.availableExercises.map((ex) {
                      return DropdownMenuItem(
                        value: ex,
                        child: Text(ex.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedExercise = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: workoutDay,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Workout Day'),
                    items: _days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => workoutDay = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: setsCtrl,
                          label: 'Sets',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Sets'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: repsCtrl,
                          label: 'Reps',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Reps'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: durationCtrl,
                    label: 'Duration (minutes)',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.positiveNumber(v, 'Duration'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesCtrl,
                    label: 'Trainer Notes',
                    hint: 'e.g. Keep back straight',
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
              text: 'Create Plan',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final now = DateTime.now();
                  final plan = WorkoutPlanModel(
                    id: '',
                    trainerId: auth.currentUser!.id,
                    trainerName: auth.currentUser!.name,
                    trainerEmail: auth.currentUser!.email,
                    memberId: selectedMember.id,
                    memberName: selectedMember.name,
                    memberEmail: selectedMember.email,
                    planName: planNameCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );

                  final starter = WorkoutExerciseModel(
                    id: '',
                    workoutPlanId: '',
                    exerciseId: selectedExercise.id,
                    exerciseName: selectedExercise.name,
                    muscleGroup: selectedExercise.muscleGroup,
                    equipment: selectedExercise.equipment,
                    instructions: selectedExercise.instructions,
                    imageUrl: selectedExercise.imageUrl,
                    videoUrl: selectedExercise.videoUrl,
                    difficulty: selectedExercise.difficulty,
                    workoutDay: workoutDay,
                    sets: int.parse(setsCtrl.text.trim()),
                    reps: int.parse(repsCtrl.text.trim()),
                    durationMinutes: int.parse(durationCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );

                  await trainer.createWorkoutPlan(
                    plan: plan,
                    starterExercise: starter,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout plan assigned successfully!'),
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

  void _showAddExerciseToPlanDialog(WorkoutPlanModel plan) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (trainer.availableExercises.isEmpty) return;

    ExerciseModel selectedExercise = trainer.availableExercises.first;
    String workoutDay = 'MONDAY';
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '12');
    final durationCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add Exercise to ${plan.planName}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ExerciseModel>(
                    value: selectedExercise,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Exercise'),
                    items: trainer.availableExercises.map((ex) {
                      return DropdownMenuItem(
                        value: ex,
                        child: Text(ex.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedExercise = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: workoutDay,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                    items: _days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => workoutDay = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: setsCtrl,
                          label: 'Sets',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Sets'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: repsCtrl,
                          label: 'Reps',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Reps'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: durationCtrl,
                    label: 'Duration (minutes)',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.positiveNumber(v, 'Duration'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesCtrl,
                    label: 'Notes / Form cues',
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
              text: 'Add Exercise',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final now = DateTime.now();
                  final ex = WorkoutExerciseModel(
                    id: '',
                    workoutPlanId: plan.id,
                    exerciseId: selectedExercise.id,
                    exerciseName: selectedExercise.name,
                    muscleGroup: selectedExercise.muscleGroup,
                    equipment: selectedExercise.equipment,
                    instructions: selectedExercise.instructions,
                    imageUrl: selectedExercise.imageUrl,
                    videoUrl: selectedExercise.videoUrl,
                    difficulty: selectedExercise.difficulty,
                    workoutDay: workoutDay,
                    sets: int.parse(setsCtrl.text.trim()),
                    reps: int.parse(repsCtrl.text.trim()),
                    durationMinutes: int.parse(durationCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );
                  await trainer.addExerciseToPlan(ex, auth.currentUser!.id);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exercise added successfully!'),
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
    final trainer = Provider.of<TrainerProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showCreatePlanDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
      body: trainer.workoutPlans.isEmpty
          ? const EmptyState(
              title: 'No Workout Plans',
              message: 'Create structured workout routines and assign them to your members.',
              icon: Icons.fitness_center_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainer.workoutPlans.length,
              itemBuilder: (ctx, idx) {
                final plan = trainer.workoutPlans[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.planName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => trainer.deleteWorkoutPlan(
                                plan.id,
                                auth.currentUser!.id,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Assigned to: ${plan.memberName ?? 'Member'} (${plan.memberEmail ?? ''})',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Exercises in this plan:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...plan.exercises.map((ex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${ex.exerciseName} (${ex.workoutDay})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${ex.sets} sets × ${ex.reps} reps • ${ex.durationMinutes} mins',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (ex.notes.isNotEmpty)
                                        Text(
                                          'Note: ${ex.notes}',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      trainer.deleteExerciseFromPlan(
                                        plan.id,
                                        ex.id,
                                        auth.currentUser!.id,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                            ),
                            label: const Text('Add Exercise to Routine'),
                            onPressed: () => _showAddExerciseToPlanDialog(plan),
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
