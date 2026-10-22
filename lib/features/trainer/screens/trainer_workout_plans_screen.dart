import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/workout_plan_model.dart';
import '../../../models/exercise_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
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

  List<ExerciseModel> _getAvailableExercises(TrainerProvider trainer) {
    if (trainer.availableExercises.isNotEmpty) {
      return trainer.availableExercises;
    }
    return FirestoreService.defaultGymExercises;
  }

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

    final exercises = _getAvailableExercises(trainer);
    UserModel selectedMember = trainer.assignedMembers.first;
    ExerciseModel selectedExercise = exercises.first;
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
                    items: exercises.map((ex) {
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
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Create Plan',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final planNameTrimmed = planNameCtrl.text.trim();
                // Duplicate routine check to avoid creating identical plans
                final isDuplicate = trainer.workoutPlans.any(
                  (p) =>
                      p.memberId == selectedMember.id &&
                      p.planName.trim().toLowerCase() ==
                          planNameTrimmed.toLowerCase(),
                );

                if (isDuplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'A routine named "$planNameTrimmed" is already assigned to ${selectedMember.name}. Please choose a unique name or add exercises to the existing plan.',
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

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
                    planName: planNameTrimmed,
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
                      SnackBar(
                        content: Text(
                          'Workout plan "$planNameTrimmed" created and assigned successfully!',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  final errStr = e.toString().toLowerCase();
                  String friendlyMsg =
                      'Failed to assign workout plan. Please try again.';
                  if (errStr.contains('permission-denied')) {
                    friendlyMsg = 'Permission error: You do not have permission to assign workout plans to this member.';
                  } else if (errStr.contains('network') ||
                      errStr.contains('unavailable')) {
                    friendlyMsg = 'Network error: Please check your connection and retry.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(friendlyMsg),
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

    final exercises = _getAvailableExercises(trainer);
    ExerciseModel selectedExercise = exercises.first;
    String workoutDay = 'MONDAY';
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '12');
    final durationCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    final customNameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isCustom = false;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select or Type Exercise',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setDialogState(() => isCustom = !isCustom);
                        },
                        child: Text(
                          isCustom ? 'Choose from list' : '+ Custom exercise',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  if (!isCustom)
                    DropdownButtonFormField<ExerciseModel>(
                      value: selectedExercise,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Exercise'),
                      items: exercises.map((ex) {
                        return DropdownMenuItem(
                          value: ex,
                          child: Text(ex.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedExercise = v);
                        }
                      },
                    )
                  else
                    CustomTextField(
                      controller: customNameCtrl,
                      label: 'Exercise Name',
                      hint: 'e.g. Incline Cable Flyes',
                      validator: (v) =>
                          AppValidators.requiredField(v, 'Exercise name'),
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
                    hint: 'e.g. Squeeze at peak contraction',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
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
                  final exName = isCustom
                      ? customNameCtrl.text.trim()
                      : selectedExercise.name;

                  final ex = WorkoutExerciseModel(
                    id: '',
                    workoutPlanId: plan.id,
                    exerciseId: isCustom ? '' : selectedExercise.id,
                    exerciseName: exName,
                    muscleGroup: isCustom
                        ? 'General'
                        : selectedExercise.muscleGroup,
                    equipment: isCustom ? '' : selectedExercise.equipment,
                    instructions: isCustom ? '' : selectedExercise.instructions,
                    imageUrl: isCustom ? '' : selectedExercise.imageUrl,
                    videoUrl: isCustom ? '' : selectedExercise.videoUrl,
                    difficulty: isCustom
                        ? 'BEGINNER'
                        : selectedExercise.difficulty,
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
                      SnackBar(
                        content: Text('Added $exName to ${plan.planName}!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  final errStr = e.toString().toLowerCase();
                  String friendlyMsg =
                      'Failed to add exercise. Please try again.';
                  if (errStr.contains('already in the routine')) {
                    friendlyMsg = e.toString().replaceAll('Exception: ', '');
                  } else if (errStr.contains('permission-denied')) {
                    friendlyMsg = 'Permission error: You do not have permission to modify this workout plan.';
                  } else if (errStr.contains('network') ||
                      errStr.contains('unavailable')) {
                    friendlyMsg = 'Network error: Please check your connection and retry.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(friendlyMsg),
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

  void _showRenamePlanDialog(WorkoutPlanModel plan) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final trainerId = auth.currentUser?.id ?? '';
    final nameCtrl = TextEditingController(text: plan.planName);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Rename Workout Plan'),
          content: Form(
            key: formKey,
            child: CustomTextField(
              controller: nameCtrl,
              label: 'Plan Name',
              hint: 'e.g. Upper Body Strength',
              validator: (v) => AppValidators.requiredField(v, 'Plan name'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Save',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  await trainer.updateWorkoutPlanName(
                    plan.id,
                    nameCtrl.text.trim(),
                    trainerId,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan name updated!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
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

  void _showEditExerciseDialog(WorkoutPlanModel plan, WorkoutExerciseModel ex) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final trainerId = auth.currentUser?.id ?? '';

    String workoutDay = ex.workoutDay;
    final setsCtrl = TextEditingController(text: ex.sets.toString());
    final repsCtrl = TextEditingController(text: ex.reps.toString());
    final durationCtrl = TextEditingController(
      text: ex.durationMinutes.toString(),
    );
    final notesCtrl = TextEditingController(text: ex.notes);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit ${ex.exerciseName}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _days.contains(workoutDay)
                        ? workoutDay
                        : _days.first,
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
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Save Changes',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final updated = WorkoutExerciseModel(
                    id: ex.id,
                    workoutPlanId: plan.id,
                    exerciseId: ex.exerciseId,
                    exerciseName: ex.exerciseName,
                    muscleGroup: ex.muscleGroup,
                    equipment: ex.equipment,
                    instructions: ex.instructions,
                    imageUrl: ex.imageUrl,
                    videoUrl: ex.videoUrl,
                    difficulty: ex.difficulty,
                    workoutDay: workoutDay,
                    sets: int.parse(setsCtrl.text.trim()),
                    reps: int.parse(repsCtrl.text.trim()),
                    durationMinutes: int.parse(durationCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: ex.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await trainer.updateExerciseInPlan(updated, trainerId);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated ${ex.exerciseName} in routine!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update exercise: $e'),
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

  void _confirmDeletePlan(WorkoutPlanModel plan) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final trainerId = auth.currentUser?.id ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Workout Plan?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${plan.planName}" assigned to ${plan.memberName ?? 'this member'}?\n\nThis will permanently remove the routine and all its exercises.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await trainer.deleteWorkoutPlan(plan.id, trainerId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Workout plan "${plan.planName}" deleted successfully.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete workout plan: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete Plan'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExercise(WorkoutPlanModel plan, WorkoutExerciseModel ex) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final trainerId = auth.currentUser?.id ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Exercise?'),
        content: Text(
          'Remove "${ex.exerciseName}" (${ex.workoutDay}) from "${plan.planName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await trainer.deleteExerciseFromPlan(plan.id, ex.id, trainerId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Removed "${ex.exerciseName}" from routine.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove exercise: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
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
      body: trainer.isLoading
          ? const LoadingView(message: 'Loading workout plans...')
          : trainer.errorMessage != null && trainer.workoutPlans.isEmpty
          ? EmptyState(
              title: 'Unable to Load Plans',
              message: trainer.errorMessage!,
              icon: Icons.wifi_off_rounded,
              action: ElevatedButton.icon(
                onPressed: () {
                  if (auth.currentUser != null) {
                    trainer.loadTrainerData(auth.currentUser!.id);
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            )
          : trainer.workoutPlans.isEmpty
          ? const EmptyState(
              title: 'No Workout Plans',
              message: 'Create structured workout routines and assign them to your members.',
              icon: Icons.fitness_center_outlined,
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (auth.currentUser != null) {
                  await trainer.loadTrainerData(auth.currentUser!.id);
                }
              },
              child: ListView.builder(
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
                              Expanded(
                                child: Text(
                                  plan.planName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                tooltip: 'Rename Plan',
                                onPressed: () => _showRenamePlanDialog(plan),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                tooltip: 'Delete Workout Plan',
                                onPressed: () => _confirmDeletePlan(plan),
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
                          if (plan.exercises.isEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.cardBorder.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'No exercises in this plan yet. Tap below to add exercises to this routine.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          tooltip: 'Edit exercise',
                                          onPressed: () =>
                                              _showEditExerciseDialog(plan, ex),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 18,
                                            color: AppColors.error,
                                          ),
                                          tooltip: 'Remove exercise',
                                          onPressed: () =>
                                              _confirmDeleteExercise(plan, ex),
                                        ),
                                      ],
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
                              onPressed: () =>
                                  _showAddExerciseToPlanDialog(plan),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
