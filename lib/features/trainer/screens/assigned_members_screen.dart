import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/trainer_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import 'trainer_chat_screen.dart';

class AssignedMembersScreen extends StatelessWidget {
  const AssignedMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Members')),
      body: trainer.assignedMembers.isEmpty
          ? const EmptyState(
              title: 'No Assigned Members',
              message: 'Members assigned to you by the administrator will appear here.',
              icon: Icons.people_outline,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainer.assignedMembers.length,
              itemBuilder: (ctx, idx) {
                final m = trainer.assignedMembers[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
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
                                    'Email: ${m.email} • Phone: ${m.phone}',
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
                                        color: AppColors.accent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TrainerChatScreen(member: m),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_outlined, size: 18),
                              label: const Text('Message Member'),
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
