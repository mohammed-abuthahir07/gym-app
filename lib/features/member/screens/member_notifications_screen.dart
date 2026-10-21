import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberNotificationsScreen extends StatelessWidget {
  const MemberNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: member.notifications.isEmpty
          ? const EmptyState(
              title: 'No Notifications',
              message: 'Workout updates, trainer announcements, and gym news will show here.',
              icon: Icons.notifications_none,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: member.notifications.length,
              itemBuilder: (ctx, idx) {
                final n = member.notifications[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: n.isRead
                      ? AppColors.surfaceCard
                      : AppColors.surfaceCard.withValues(alpha: 0.9),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.isRead
                          ? AppColors.surface
                          : AppColors.primary,
                      child: Icon(
                        n.isRead
                            ? Icons.notifications_outlined
                            : Icons.notifications_active,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.message),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatDateTime(n.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: !n.isRead
                        ? TextButton(
                            onPressed: () {
                              if (user != null) {
                                member.markNotificationRead(n.id, user.id);
                              }
                            },
                            child: const Text('Mark Read'),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
