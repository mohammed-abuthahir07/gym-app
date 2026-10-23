import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class TrainerNotificationsScreen extends StatelessWidget {
  const TrainerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Notifications')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await trainer.loadTrainerData(user.id);
          }
        },
        child: trainer.notifications.isEmpty
            ? const EmptyState(
                title: 'No Notifications Available',
                message: 'Gym announcements, schedule updates, and messages from administration will show here.',
                icon: Icons.notifications_none,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: trainer.notifications.length,
                itemBuilder: (ctx, idx) {
                  final n = trainer.notifications[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: n.isRead
                        ? AppColors.surfaceCard
                        : AppColors.surfaceCard.withValues(alpha: 0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: n.isRead
                            ? AppColors.cardBorder
                            : theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: n.isRead ? 1 : 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: n.isRead
                            ? AppColors.surface
                            : theme.colorScheme.primary,
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
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            n.message,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
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
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                foregroundColor: theme.colorScheme.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                if (user != null) {
                                  trainer.markNotificationRead(n.id, user.id);
                                }
                              },
                              child: const Text('Mark Read'),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
