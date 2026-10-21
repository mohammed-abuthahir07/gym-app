import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/challenge_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ChallengeManagementScreen extends StatefulWidget {
  const ChallengeManagementScreen({super.key});

  @override
  State<ChallengeManagementScreen> createState() =>
      _ChallengeManagementScreenState();
}

class _ChallengeManagementScreenState extends State<ChallengeManagementScreen> {
  void _showAddChallengeDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final startCtrl = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
    final endCtrl = TextEditingController(
      text: DateTime.now()
          .add(const Duration(days: 30))
          .toString()
          .split(' ')[0],
    );
    final rewardCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Fitness Challenge'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleCtrl,
                    label: 'Challenge Title',
                    hint: 'e.g. 30 Day Fitness Challenge',
                    validator: (v) => AppValidators.requiredField(v, 'Title'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description',
                    hint: 'e.g. Complete workouts for 30 days',
                    maxLines: 2,
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: startCtrl,
                          label: 'Start Date (YYYY-MM-DD)',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'Start date'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: endCtrl,
                          label: 'End Date (YYYY-MM-DD)',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'End date'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: rewardCtrl,
                    label: 'Reward / Prize',
                    hint: 'e.g. Free protein shaker / gym t-shirt',
                    validator: (v) => AppValidators.requiredField(v, 'Reward'),
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
              text: 'Create Challenge',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final challenge = ChallengeModel(
                    id: '',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    startDate: startCtrl.text.trim(),
                    endDate: endCtrl.text.trim(),
                    reward: rewardCtrl.text.trim(),
                    status: 'ACTIVE',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).addChallenge(challenge);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Challenge created successfully!'),
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
      appBar: AppBar(title: const Text('Fitness Challenges')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddChallengeDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Challenge'),
      ),
      body: admin.challenges.isEmpty
          ? const EmptyState(
              title: 'No Challenges',
              message: 'Engage members by creating goal-oriented gym challenges and milestone rewards.',
              icon: Icons.emoji_events_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.challenges.length,
              itemBuilder: (ctx, idx) {
                final ch = admin.challenges[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.accent,
                      child: Icon(Icons.emoji_events, color: Colors.white),
                    ),
                    title: Text(
                      ch.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ch.description),
                        const SizedBox(height: 4),
                        Text(
                          'Reward: ${ch.reward}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Duration: ${ch.startDate} to ${ch.endDate}',
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
                      onPressed: () => admin.deleteChallenge(ch.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
