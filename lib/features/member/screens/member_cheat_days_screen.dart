import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/cheat_day_model.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class MemberCheatDaysScreen extends StatefulWidget {
  const MemberCheatDaysScreen({super.key});

  @override
  State<MemberCheatDaysScreen> createState() => _MemberCheatDaysScreenState();
}

class _MemberCheatDaysScreenState extends State<MemberCheatDaysScreen> {
  void _showAddCheatDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final member = Provider.of<MemberProvider>(context, listen: false);
    if (auth.currentUser == null) return;

    final dateCtrl = TextEditingController(
      text: AppDateUtils.todayDateString(),
    );
    final foodCtrl = TextEditingController(text: 'Pizza');
    final qtyCtrl = TextEditingController(text: '2 slices');
    final calCtrl = TextEditingController(text: '600');
    final notesCtrl = TextEditingController(text: 'Weekend treat');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Cheat Meal / Activity'),
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
                  CustomTextField(
                    controller: foodCtrl,
                    label: 'Food Item',
                    hint: 'e.g. Pizza / Burger / Ice cream',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Food name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: qtyCtrl,
                    label: 'Quantity',
                    hint: 'e.g. 2 slices / 1 bowl',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Quantity'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: calCtrl,
                    label: 'Estimated Calories',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.nonNegativeNumber(v, 'Calories'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesCtrl,
                    label: 'Notes (optional)',
                    hint: 'e.g. Celebrated with family',
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
              text: 'Log Cheat Day',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final now = DateTime.now();
                  final c = CheatDayModel(
                    id: '',
                    memberId: auth.currentUser!.id,
                    memberName: auth.currentUser!.name,
                    memberEmail: auth.currentUser!.email,
                    cheatDate: dateCtrl.text.trim(),
                    foodName: foodCtrl.text.trim(),
                    quantity: qtyCtrl.text.trim(),
                    calories: int.parse(calCtrl.text.trim()),
                    notes: notesCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );
                  await member.addCheatDay(c);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cheat activity recorded!'),
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
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cheat-Day Logger')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddCheatDialog,
        icon: const Icon(Icons.add),
        label: const Text('Log Cheat Meal'),
      ),
      body: member.cheatDays.isEmpty
          ? const EmptyState(
              title: 'No Cheat Meals Recorded',
              message: 'Keep an honest log of your treats so your coach can balance your nutrition.',
              icon: Icons.fastfood_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: member.cheatDays.length,
              itemBuilder: (ctx, idx) {
                final c = member.cheatDays[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.warning,
                      child: Icon(Icons.fastfood, color: Colors.white),
                    ),
                    title: Text(
                      '${c.foodName} (${c.quantity})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${c.cheatDate} • ${c.calories} kcal'),
                        if (c.notes != null && c.notes!.isNotEmpty)
                          Text(
                            'Note: ${c.notes}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        if (auth.currentUser != null) {
                          member.deleteCheatDay(c.id, auth.currentUser!.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
