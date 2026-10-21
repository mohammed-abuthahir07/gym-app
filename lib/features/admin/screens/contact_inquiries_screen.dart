import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class ContactInquiriesScreen extends StatelessWidget {
  const ContactInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Enquiries')),
      body: admin.contacts.isEmpty
          ? const EmptyState(
              title: 'No Enquiries',
              message: 'Public inquiries submitted through the contact form will appear here.',
              icon: Icons.mail_outline,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.contacts.length,
              itemBuilder: (ctx, idx) {
                final c = admin.contacts[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.name,
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
                                color: c.isRead
                                    ? AppColors.surface
                                    : AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                c.status,
                                style: TextStyle(
                                  color: c.isRead
                                      ? AppColors.textMuted
                                      : AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email: ${c.email} • Phone: ${c.phone}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppDateUtils.formatDateTime(c.createdAt),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Row(
                              children: [
                                if (!c.isRead)
                                  TextButton(
                                    onPressed: () =>
                                        admin.markContactRead(c.id),
                                    child: const Text('Mark Read'),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => admin.deleteContact(c.id),
                                ),
                              ],
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
