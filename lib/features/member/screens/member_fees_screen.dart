import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/member_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberFeesScreen extends StatelessWidget {
  const MemberFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Status & Paid History')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current month status card
            Card(
              color: member.currentMonthPaymentStatus == 'PAID'
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          member.currentMonthPaymentStatus == 'PAID'
                          ? AppColors.success
                          : AppColors.error,
                      child: Icon(
                        member.currentMonthPaymentStatus == 'PAID'
                            ? Icons.check
                            : Icons.warning_amber_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Month Membership',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: ${member.currentMonthPaymentStatus}',
                            style: TextStyle(
                              color: member.currentMonthPaymentStatus == 'PAID'
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            member.fees.isEmpty
                ? const EmptyState(
                    title: 'No Fee Invoices',
                    message: 'Receipts and payment history recorded by administration will show here.',
                    icon: Icons.payments_outlined,
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: member.fees.length,
                    itemBuilder: (ctx, idx) {
                      final f = member.fees[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: f.isPaid
                                ? AppColors.success
                                : AppColors.warning,
                            child: Icon(
                              f.isPaid ? Icons.check : Icons.access_time,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '₹${f.feeAmount.toStringAsFixed(0)} - ${f.feeMonth} ${f.feeYear}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Payment Date: ${f.feeDate}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: f.isPaid
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              f.paymentStatus,
                              style: TextStyle(
                                color: f.isPaid
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
