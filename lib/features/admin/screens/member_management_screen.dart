import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  void _showAssignTrainerDialog(UserModel member) {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final activeTrainers = admin.trainers.where((t) => t.isActive).toList();

    if (activeTrainers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active trainers available to assign.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    UserModel? selectedTrainer = activeTrainers.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Assign Trainer to ${member.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select an active trainer:'),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserModel>(
                  value: selectedTrainer,
                  isExpanded: true,
                  items: activeTrainers.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(
                        '${t.name} (${t.email})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedTrainer = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedTrainer == null) return;
                await admin.assignTrainerToMember(
                  memberId: member.id,
                  trainerId: selectedTrainer!.id,
                  trainerName: selectedTrainer!.name,
                  trainerEmail: selectedTrainer!.email,
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Assigned ${selectedTrainer!.name} to ${member.name}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Assign'),
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
      appBar: AppBar(title: const Text('Member Management')),
      body: admin.members.isEmpty
          ? const EmptyState(
              title: 'No Members Registered',
              message: 'Registered members will appear here for oversight and trainer assignment.',
              icon: Icons.people_outline,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.members.length,
              itemBuilder: (ctx, idx) {
                final m = admin.members[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: m.isActive
                                  ? AppColors.primary
                                  : AppColors.surface,
                              child: Text(
                                m.name.isNotEmpty
                                    ? m.name[0].toUpperCase()
                                    : 'M',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Email: ${m.email} • ${m.phone}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (m.fitnessGoal != null &&
                                      m.fitnessGoal!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Goal: ${m.fitnessGoal}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: m.isActive
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                m.status,
                                style: TextStyle(
                                  color: m.isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.fitness_center,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  m.trainerName != null
                                      ? 'Trainer: ${m.trainerName}'
                                      : 'No Trainer Assigned',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: m.trainerName != null
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (m.trainerId != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.person_remove,
                                      size: 18,
                                      color: AppColors.warning,
                                    ),
                                    tooltip: 'Remove Trainer',
                                    onPressed: () =>
                                        admin.removeTrainerFromMember(m.id),
                                  ),
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.person_add_alt_1,
                                    size: 16,
                                  ),
                                  label: Text(
                                    m.trainerId != null ? 'Change' : 'Assign',
                                  ),
                                  onPressed: m.isActive
                                      ? () => _showAssignTrainerDialog(m)
                                      : null,
                                ),
                                if (m.isActive)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.block,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    tooltip: 'Deactivate Member',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                            'Deactivate Member?',
                                          ),
                                          content: Text(
                                            'Are you sure you want to deactivate ${m.name}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Deactivate',
                                                style: TextStyle(
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await admin.deactivateMember(m.id);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ],
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
