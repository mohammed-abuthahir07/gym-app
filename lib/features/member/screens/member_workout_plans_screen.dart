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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Workout Plans')),
      body: member.workoutPlans.isEmpty
          ? const EmptyState(
              title: 'No Workout Routine Assigned',
              message:
                  'Your assigned coach will prepare customized exercise programs for you.',
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.planName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (plan.trainerName != null &&
                                        plan.trainerName!.isNotEmpty)
                                      Text(
                                        'Coach: ${plan.trainerName}',
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Exercises in this Routine:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
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
                                color: theme
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.2,
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
                              final isDone = member.todayCompletedExerciseIds
                                  .contains(ex.id);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDone
                                        ? AppColors.success.withValues(
                                            alpha: 0.4,
                                          )
                                        : theme.dividerColor.withValues(
                                            alpha: 0.2,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                ex.exerciseName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.15),
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
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.65),
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (ex.notes.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              'Cue: ${ex.notes}',
                                              style: TextStyle(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (isDone)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.success,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: AppColors.success,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Done',
                                              style: TextStyle(
                                                color: AppColors.success,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          minimumSize: const Size(60, 32),
                                          elevation: 0,
                                          textStyle: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (user == null) return;
                                          try {
                                            await member
                                                .completeWorkoutExercise(
                                                  memberId: user.id,
                                                  workoutPlanExerciseId: ex.id,
                                                );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
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
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
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
