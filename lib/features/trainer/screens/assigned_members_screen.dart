import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../models/member_profile_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../shared/widgets/empty_state.dart';
import 'trainer_chat_screen.dart';

class AssignedMembersScreen extends StatelessWidget {
  const AssignedMembersScreen({super.key});

  void _showMemberProfileDialog(BuildContext context, UserModel member) async {
    final service = FirestoreService();
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<MemberProfileModel?>(
        future: service.getMemberProfile(member.id),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final prof = snap.data;
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(member.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Email', member.email),
                  _infoRow('Phone', member.phone),
                  _infoRow('Status', member.status),
                  _infoRow(
                    'Goal',
                    prof?.fitnessGoal ?? member.fitnessGoal ?? 'Not set',
                  ),
                  _infoRow(
                    'Age',
                    prof != null && prof.age > 0
                        ? '${prof.age} years'
                        : 'Not set',
                  ),
                  _infoRow(
                    'Height',
                    prof != null && prof.height > 0
                        ? '${prof.height} cm'
                        : 'Not set',
                  ),
                  _infoRow(
                    'Weight',
                    prof != null && prof.weight > 0
                        ? '${prof.weight} kg'
                        : 'Not set',
                  ),
                  _infoRow(
                    'Medical Notes',
                    prof?.medicalNotes.isNotEmpty == true
                        ? prof!.medicalNotes
                        : 'None recorded',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainerChatScreen(member: member),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text('Chat'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
                final checkIns = trainer.memberCheckInDays[m.id] ?? 0;

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
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Check-ins: $checkIns days',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (m.fitnessGoal != null &&
                                          m.fitnessGoal!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Goal: ${m.fitnessGoal}',
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
                              onPressed: () =>
                                  _showMemberProfileDialog(context, m),
                              icon: const Icon(Icons.info_outline, size: 16),
                              label: const Text('View Profile'),
                            ),
                            const SizedBox(width: 8),
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
                              icon: const Icon(Icons.chat_outlined, size: 16),
                              label: const Text('Message'),
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
