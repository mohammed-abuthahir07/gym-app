import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/diet_plan_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class TrainerDietPlansScreen extends StatefulWidget {
  const TrainerDietPlansScreen({super.key});

  @override
  State<TrainerDietPlansScreen> createState() => _TrainerDietPlansScreenState();
}

class _TrainerDietPlansScreenState extends State<TrainerDietPlansScreen> {
  final List<String> _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  final List<String> _meals = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'];

  void _showAddDietDialog() {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (trainer.assignedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No assigned members available.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    UserModel selectedMember = trainer.assignedMembers.first;
    String dietDay = 'MONDAY';
    String mealType = 'BREAKFAST';
    final foodCtrl = TextEditingController(text: 'Oats with banana');
    final calCtrl = TextEditingController(text: '350');
    final proteinCtrl = TextEditingController(text: '20');
    final notesCtrl = TextEditingController(text: 'Eat before workout');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Assign Diet Meal Plan'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UserModel>(
                    value: selectedMember,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Member'),
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: dietDay,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Day',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          items: _days
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => dietDay = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: mealType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Meal',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          items: _meals
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => mealType = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: foodCtrl,
                    label: 'Food Item & Description',
                    hint: 'e.g. Oats with banana / Grilled chicken rice',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Food name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: calCtrl,
                          label: 'Calories (kcal)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.nonNegativeNumber(v, 'Calories'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: proteinCtrl,
                          label: 'Protein (g)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.nonNegativeNumber(v, 'Protein'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesCtrl,
                    label: 'Instructions / Notes',
                    hint: 'e.g. Add vegetables, drink water',
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
              text: 'Save Meal Plan',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final now = DateTime.now();
                  final plan = DietPlanModel(
                    id: '',
                    trainerId: auth.currentUser!.id,
                    trainerName: auth.currentUser!.name,
                    trainerEmail: auth.currentUser!.email,
                    memberId: selectedMember.id,
                    memberName: selectedMember.name,
                    memberEmail: selectedMember.email,
                    dietDay: dietDay,
                    mealType: mealType,
                    foodName: foodCtrl.text.trim(),
                    calories: int.parse(calCtrl.text.trim()),
                    protein: double.parse(proteinCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );
                  await trainer.addDietPlan(plan);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diet plan saved!'),
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

  void _showEditDietDialog(DietPlanModel plan) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);

    String dietDay = plan.dietDay;
    String mealType = plan.mealType;
    final foodCtrl = TextEditingController(text: plan.foodName);
    final calCtrl = TextEditingController(text: plan.calories.toString());
    final proteinCtrl = TextEditingController(
      text: plan.protein.toStringAsFixed(0),
    );
    final notesCtrl = TextEditingController(text: plan.notes);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Edit ${plan.mealType} for ${plan.memberName ?? 'Member'}',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _days.contains(dietDay)
                              ? dietDay
                              : _days.first,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Day'),
                          items: _days
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => dietDay = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _meals.contains(mealType)
                              ? mealType
                              : _meals.first,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Meal'),
                          items: _meals
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => mealType = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: foodCtrl,
                    label: 'Food Item & Description',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Food name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: calCtrl,
                          label: 'Calories (kcal)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Calories'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: proteinCtrl,
                          label: 'Protein (g)',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Protein'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesCtrl,
                    label: 'Notes / Instructions',
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
              text: 'Save',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final updated = DietPlanModel(
                    id: plan.id,
                    trainerId: plan.trainerId,
                    trainerName: plan.trainerName,
                    trainerEmail: plan.trainerEmail,
                    memberId: plan.memberId,
                    memberName: plan.memberName,
                    memberEmail: plan.memberEmail,
                    dietDay: dietDay,
                    mealType: mealType,
                    foodName: foodCtrl.text.trim(),
                    calories: int.parse(calCtrl.text.trim()),
                    protein: double.parse(proteinCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: plan.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await trainer.updateDietPlan(updated);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diet plan updated!'),
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
      appBar: AppBar(title: const Text('Diet & Meal Plans')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddDietDialog,
        icon: const Icon(Icons.add),
        label: const Text('Assign Diet'),
      ),
      body: trainer.dietPlans.isEmpty
          ? const EmptyState(
              title: 'No Diet Plans',
              message: 'Assign balanced nutrition, meal types, and macros for members.',
              icon: Icons.restaurant_menu,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainer.dietPlans.length,
              itemBuilder: (ctx, idx) {
                final d = trainer.dietPlans[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.success,
                      child: Text(
                        d.mealType.isNotEmpty ? d.mealType[0] : 'M',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      '${d.foodName} (${d.dietDay})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member: ${d.memberName ?? 'Client'} • Meal: ${d.mealType}',
                        ),
                        Text(
                          '${d.calories} kcal • ${d.protein.toStringAsFixed(0)}g protein',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (d.notes.isNotEmpty)
                          Text(
                            'Note: ${d.notes}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          tooltip: 'Edit Diet Plan',
                          onPressed: () => _showEditDietDialog(d),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'Delete Diet Plan',
                          onPressed: () => trainer.deleteDietPlan(
                            d.id,
                            auth.currentUser!.id,
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
