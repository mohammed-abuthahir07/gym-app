import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/member_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberExercisesScreen extends StatelessWidget {
  const MemberExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      body: member.exercises.isEmpty
          ? const EmptyState(
              title: 'No Exercises Available',
              message: 'The gym exercise library is being updated.',
              icon: Icons.fitness_center_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: member.exercises.length,
              itemBuilder: (ctx, idx) {
                final ex = member.exercises[idx];
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
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
                          'Muscle Group: ${ex.muscleGroup} • Equipment: ${ex.equipment}',
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
