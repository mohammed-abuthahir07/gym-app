import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/member_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberChallengesScreen extends StatelessWidget {
  const MemberChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Challenges')),
      body: member.challenges.isEmpty
          ? const EmptyState(
              title: 'No Active Challenges',
              message: 'Check back soon for upcoming challenges and milestone rewards.',
              icon: Icons.emoji_events_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: member.challenges.length,
              itemBuilder: (ctx, idx) {
                final ch = member.challenges[idx];
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
                          'Dates: ${ch.startDate} to ${ch.endDate}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
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
