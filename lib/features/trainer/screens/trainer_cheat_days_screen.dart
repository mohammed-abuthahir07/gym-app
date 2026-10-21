import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/trainer_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class TrainerCheatDaysScreen extends StatelessWidget {
  const TrainerCheatDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Member Cheat-Day Logs')),
      body: trainer.cheatDays.isEmpty
          ? const EmptyState(
              title: 'No Cheat Activities Logged',
              message: 'When your assigned members log cheat meals or snacks, they appear here.',
              icon: Icons.fastfood_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainer.cheatDays.length,
              itemBuilder: (ctx, idx) {
                final c = trainer.cheatDays[idx];
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
                        Text(
                          'Member: ${c.memberName ?? 'Member'} • Date: ${c.cheatDate}',
                        ),
                        Text(
                          '${c.calories} calories',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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
                  ),
                );
              },
            ),
    );
  }
}
