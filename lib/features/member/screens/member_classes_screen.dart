import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/member_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberClassesScreen extends StatelessWidget {
  const MemberClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Class Schedules')),
      body: member.schedules.isEmpty
          ? const EmptyState(
              title: 'No Classes Scheduled',
              message:
                  'Classes scheduled by your assigned trainer will show here.',
              icon: Icons.calendar_today_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: member.schedules.length,
              itemBuilder: (ctx, idx) {
                final s = member.schedules[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.timer, color: Colors.white),
                    ),
                    title: Text(
                      s.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${s.classDate} • ${s.startTime} - ${s.endTime}\nCapacity: ${s.capacity} members',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
