import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberWorkoutPlansScreen extends StatelessWidget {
  const MemberWorkoutPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Workout Plans')),
      body: member.workoutPlans.isEmpty
          ? const EmptyState(
              title: 'No Workout Routine Assigned',
              message: 'Your assigned coach will prepare customized exercise programs for you.',
              icon: Icons.fitness_center_outlined,
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await member.loadMemberData(user.id, user.trainerId);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: member.workoutPlans.length,
                itemBuilder: (ctx, idx) {
                  final plan = member.workoutPlans[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.planName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan.trainerName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Coach: ${plan.trainerName}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Text(
                            'Exercises in this Routine:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (plan.exercises.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
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
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No exercises have been added to this routine yet.',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...plan.exercises.map((ex) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                ex.exerciseName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  ex.workoutDay,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${ex.sets} sets × ${ex.reps} reps • ${ex.durationMinutes} mins',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (ex.notes.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Cue: ${ex.notes}',
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (user == null) return;
                                        try {
                                          await member.completeWorkoutExercise(
                                            memberId: user.id,
                                            workoutPlanExerciseId: ex.id,
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Completed exercise for today!',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.success,
                                                  ),
                                                );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.toString().replaceAll(
                                                        'Exception: ',
                                                        '',
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        AppColors.warning,
                                                  ),
                                                );
                                          }
                                        }
                                      },
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              );
                            }),
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
