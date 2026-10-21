import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/stat_card.dart';

class AnalyticsReportsScreen extends StatelessWidget {
  const AnalyticsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Revenue Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Current Month Revenue',
                  value: '₹${admin.currentMonthRevenue.toStringAsFixed(0)}',
                  icon: Icons.currency_rupee,
                  color: AppColors.success,
                ),
                StatCard(
                  title: 'Current Year Revenue',
                  value: '₹${admin.currentYearRevenue.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                  color: AppColors.info,
                ),
                StatCard(
                  title: 'Total Revenue',
                  value: '₹${admin.totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.account_balance,
                  color: AppColors.primary,
                ),
                StatCard(
                  title: 'Current Month Unpaid',
                  value: '${admin.currentMonthUnpaidCount}',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  subtitle: 'Pending fee payments',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Growth Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMetricRow(
                      label: 'Total Registered Members',
                      value: '${admin.members.length}',
                      icon: Icons.people,
                      color: AppColors.info,
                    ),
                    const Divider(color: AppColors.cardBorder),
                    _buildMetricRow(
                      label: 'Active Gym Members',
                      value: '${admin.members.where((m) => m.isActive).length}',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    const Divider(color: AppColors.cardBorder),
                    _buildMetricRow(
                      label: 'Active Trainers & Coaches',
                      value:
                          '${admin.trainers.where((t) => t.isActive).length}',
                      icon: Icons.sports,
                      color: AppColors.accent,
                    ),
                    const Divider(color: AppColors.cardBorder),
                    _buildMetricRow(
                      label: 'Active Subscriptions / Plans',
                      value: '${admin.plans.where((p) => p.isActive).length}',
                      icon: Icons.card_membership,
                      color: AppColors.warning,
                    ),
                    const Divider(color: AppColors.cardBorder),
                    _buildMetricRow(
                      label: 'Active Fitness Challenges',
                      value:
                          '${admin.challenges.where((c) => c.isActive).length}',
                      icon: Icons.emoji_events,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
