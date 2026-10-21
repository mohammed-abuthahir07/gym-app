import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/member_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class MemberDietPlansScreen extends StatefulWidget {
  const MemberDietPlansScreen({super.key});

  @override
  State<MemberDietPlansScreen> createState() => _MemberDietPlansScreenState();
}

class _MemberDietPlansScreenState extends State<MemberDietPlansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final todayName = AppDateUtils.currentDayName();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diet & Nutrition'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: "Today's Meals ($todayName)"),
            const Tab(text: 'Full Weekly Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Today's Meals
          member.todayDietPlans.isEmpty
              ? const EmptyState(
                  title: 'No Meals Scheduled for Today',
                  message: 'No specific diet plan set for today. Follow your balanced nutrition guidelines.',
                  icon: Icons.restaurant,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: member.todayDietPlans.length,
                  itemBuilder: (ctx, idx) {
                    final d = member.todayDietPlans[idx];
                    return _buildDietCard(d);
                  },
                ),

          // Full Plan
          member.dietPlans.isEmpty
              ? const EmptyState(
                  title: 'No Assigned Diet Plans',
                  message: 'Your personal coach will configure meal schedules and macro targets.',
                  icon: Icons.restaurant_menu,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: member.dietPlans.length,
                  itemBuilder: (ctx, idx) {
                    final d = member.dietPlans[idx];
                    return _buildDietCard(d);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDietCard(dynamic d) {
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        d.mealType,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      d.dietDay,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${d.calories} kcal',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              d.foodName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Protein target: ${d.protein.toStringAsFixed(0)}g',
              style: const TextStyle(color: AppColors.accent, fontSize: 13),
            ),
            if (d.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Coach Notes: ${d.notes}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
