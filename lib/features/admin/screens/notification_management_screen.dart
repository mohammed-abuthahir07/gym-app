import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() =>
      _NotificationManagementScreenState();
}

class _NotificationManagementScreenState
    extends State<NotificationManagementScreen> {
  void _showBroadcastDialog() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String target = 'ALL_MEMBERS';
    String? individualId;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final admin = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Send Broadcast Notification'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: target,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Target Audience',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ALL_MEMBERS',
                        child: Text('All Members'),
                      ),
                      DropdownMenuItem(
                        value: 'ALL_TRAINERS',
                        child: Text('All Trainers'),
                      ),
                      DropdownMenuItem(
                        value: 'INDIVIDUAL_MEMBER',
                        child: Text('Specific Member'),
                      ),
                      DropdownMenuItem(
                        value: 'INDIVIDUAL_TRAINER',
                        child: Text('Specific Trainer'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          target = v;
                          individualId = null;
                        });
                      }
                    },
                  ),
                  if (target == 'INDIVIDUAL_MEMBER') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: individualId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Member',
                      ),
                      items: admin.members.map((m) {
                        return DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => individualId = v),
                      validator: (v) =>
                          v == null ? 'Please select a member' : null,
                    ),
                  ],
                  if (target == 'INDIVIDUAL_TRAINER') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: individualId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Trainer',
                      ),
                      items: admin.trainers.map((t) {
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => individualId = v),
                      validator: (v) =>
                          v == null ? 'Please select a trainer' : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: titleCtrl,
                    label: 'Notification Title',
                    hint: 'e.g. Gym Holiday / Schedule Update',
                    validator: (v) => AppValidators.requiredField(v, 'Title'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: msgCtrl,
                    label: 'Message Content',
                    maxLines: 3,
                    validator: (v) => AppValidators.requiredField(v, 'Message'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Send Broadcast',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  String actualRole = target;
                  if (target == 'INDIVIDUAL_MEMBER') actualRole = 'MEMBER';
                  if (target == 'INDIVIDUAL_TRAINER') actualRole = 'TRAINER';

                  await admin.broadcastNotification(
                    title: titleCtrl.text.trim(),
                    message: msgCtrl.text.trim(),
                    targetRole: actualRole,
                    individualRecipientId: individualId,
                  );

                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification broadcast successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Notifications')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showBroadcastDialog,
        icon: const Icon(Icons.send),
        label: const Text('Send Notification'),
      ),
      body: admin.notifications.isEmpty
          ? const EmptyState(
              title: 'No Notifications Sent',
              message:
                  'Broadcast gym news, schedule updates, or fee reminders.',
              icon: Icons.notifications_none,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.notifications.length,
              itemBuilder: (ctx, idx) {
                final n = admin.notifications[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.info,
                      child: Icon(Icons.campaign, color: Colors.white),
                    ),
                    title: Text(
                      n.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.message),
                        const SizedBox(height: 4),
                        Text(
                          'Target: ${n.recipientRole} • ${AppDateUtils.formatDateTime(n.createdAt)}',
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
