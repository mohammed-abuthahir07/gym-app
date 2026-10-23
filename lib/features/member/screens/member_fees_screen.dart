import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';

class MemberFeesScreen extends StatelessWidget {
  const MemberFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final currentMonthName = AppDateUtils.currentMonthName();
    final currentYear = AppDateUtils.currentYear();

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Status & Paid History')),
      body: member.isLoading && member.fees.isEmpty
          ? const LoadingView(message: 'Loading fee and payment history...')
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await member.loadMemberData(user.id, user.trainerId);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current month status card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: member.currentMonthPaymentStatus == 'PAID'
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  member.currentMonthPaymentStatus == 'PAID'
                                  ? AppColors.success
                                  : AppColors.error,
                              child: Icon(
                                member.currentMonthPaymentStatus == 'PAID'
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currentMonthName $currentYear Membership',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text(
                                        'Status: ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              member.currentMonthPaymentStatus ==
                                                  'PAID'
                                              ? AppColors.success
                                              : AppColors.error,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          member.currentMonthPaymentStatus,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${member.fees.length} Invoices',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    member.fees.isEmpty
                        ? const EmptyState(
                            title: 'No Fee Invoices',
                            message: 'Official payment receipts and fee records verified by administration will show here.',
                            icon: Icons.payments_outlined,
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: member.fees.length,
                            itemBuilder: (ctx, idx) {
                              final f = member.fees[idx];
                              final isPaid = f.isPaid;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: isPaid
                                            ? AppColors.success.withValues(
                                                alpha: 0.2,
                                              )
                                            : AppColors.warning.withValues(
                                                alpha: 0.2,
                                              ),
                                        child: Icon(
                                          isPaid
                                              ? Icons.check
                                              : Icons.access_time,
                                          color: isPaid
                                              ? AppColors.success
                                              : AppColors.warning,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '₹${f.feeAmount.toStringAsFixed(0)} • ${f.feeMonth} ${f.feeYear}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Payment Date: ${f.feeDate.isNotEmpty ? f.feeDate : "Recorded"}',
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? AppColors.success.withValues(
                                                  alpha: 0.15,
                                                )
                                              : AppColors.warning.withValues(
                                                  alpha: 0.15,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          f.paymentStatus,
                                          style: TextStyle(
                                            color: isPaid
                                                ? AppColors.success
                                                : AppColors.warning,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
