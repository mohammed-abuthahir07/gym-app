import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/image_slider.dart';
import '../../../shared/widgets/role_drawer_header.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../settings/screens/theme_settings_screen.dart';
import 'trainer_management_screen.dart';
import 'member_management_screen.dart';
import 'plan_management_screen.dart';
import 'promotion_management_screen.dart';
import 'challenge_management_screen.dart';
import 'exercise_management_screen.dart';
import 'notification_management_screen.dart';
import 'fee_management_screen.dart';
import 'contact_inquiries_screen.dart';
import 'analytics_reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _adminImages = const [
    'assets/admin/img1.jpg',
    'assets/admin/img2.jpg',
    'assets/admin/img3.jpg',
    'assets/admin/img4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadAllData();
    });
  }

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Admin Portal',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 22),
            tooltip: 'Theme & Appearance',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: () => admin.loadAllData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Sign Out',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, admin, auth, theme),
      body: admin.isLoading
          ? const LoadingView(message: 'Loading administrative dashboard...')
          : (admin.errorMessage != null &&
                admin.members.isEmpty &&
                admin.trainers.isEmpty)
          ? EmptyState(
              title: 'Unable to Load Dashboard',
              message: admin.errorMessage!,
              icon: Icons.cloud_off_rounded,
              action: ElevatedButton.icon(
                onPressed: () => admin.loadAllData(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => admin.loadAllData(),
              child: isWide
                  ? _buildWideLayout(admin, auth, theme)
                  : _buildNarrowLayout(admin, auth, theme),
            ),
    );
  }

  // ─── Responsive narrow (phone) layout ──────────────────────────────────────
  Widget _buildNarrowLayout(
    AdminProvider admin,
    AuthProvider auth,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image slider with welcome overlay
          ImageSlider(
            imagePaths: _adminImages,
            height: 245,
            overlayContent: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ADMIN CONTROL PANEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hello, ${auth.currentUser?.name ?? 'Admin'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pulse & Power Administration',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Overview & Statistics'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _buildStatCards(admin, theme),
                ),
                const SizedBox(height: 28),

                _buildSectionLabel('Management Hub'),
                const SizedBox(height: 12),
                _buildManagementGrid(admin, theme, crossAxisCount: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Wide (tablet/desktop) layout with side rail ───────────────────────────
  Widget _buildWideLayout(
    AdminProvider admin,
    AuthProvider auth,
    ThemeData theme,
  ) {
    final pages = _allPages(admin, theme);
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          extended: true,
          minExtendedWidth: 200,
          backgroundColor: theme.colorScheme.surface,
          destinations: [
            const NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            ..._navRailDestinations(),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedIndex == 0
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${auth.currentUser?.name ?? 'Admin'} 👋',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pulse & Power Administration',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Overview & Statistics'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _buildStatCards(admin, theme),
                      ),
                      const SizedBox(height: 28),
                      _buildSectionLabel('Management Hub'),
                      const SizedBox(height: 12),
                      _buildManagementGrid(admin, theme, crossAxisCount: 4),
                    ],
                  ),
                )
              : pages[_selectedIndex - 1],
        ),
      ],
    );
  }

  List<Widget> _allPages(AdminProvider admin, ThemeData theme) {
    return [
      const MemberManagementScreen(),
      const TrainerManagementScreen(),
      const FeeManagementScreen(),
      const PlanManagementScreen(),
      const PromotionManagementScreen(),
      const ChallengeManagementScreen(),
      const ExerciseManagementScreen(),
      const NotificationManagementScreen(),
      const ContactInquiriesScreen(),
      const AnalyticsReportsScreen(),
    ];
  }

  List<NavigationRailDestination> _navRailDestinations() {
    const items = [
      ('Members', Icons.people_outline, Icons.people),
      ('Trainers', Icons.sports_outlined, Icons.sports),
      ('Fees', Icons.payments_outlined, Icons.payments),
      ('Plans', Icons.card_membership_outlined, Icons.card_membership),
      ('Promotions', Icons.local_offer_outlined, Icons.local_offer),
      ('Challenges', Icons.emoji_events_outlined, Icons.emoji_events),
      ('Exercises', Icons.fitness_center_outlined, Icons.fitness_center),
      (
        'Notifications',
        Icons.notifications_active_outlined,
        Icons.notifications_active,
      ),
      ('Enquiries', Icons.mail_outline, Icons.mail),
      ('Analytics', Icons.bar_chart_outlined, Icons.bar_chart),
    ];
    return items
        .map(
          (e) => NavigationRailDestination(
            icon: Icon(e.$2),
            selectedIcon: Icon(e.$3),
            label: Text(e.$1),
          ),
        )
        .toList();
  }

  Widget _buildSectionLabel(String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStatCards(AdminProvider admin, ThemeData theme) {
    return [
      StatCard(
        title: 'Total Members',
        value: '${admin.members.length}',
        icon: Icons.people_rounded,
        color: AppColors.info,
        subtitle: '${admin.members.where((m) => m.isActive).length} active',
      ),
      StatCard(
        title: 'Trainers',
        value: '${admin.trainers.length}',
        icon: Icons.sports_rounded,
        color: AppColors.accent,
        subtitle: '${admin.trainers.where((t) => t.isActive).length} active',
      ),
      StatCard(
        title: 'Month Revenue',
        value: '₹${admin.currentMonthRevenue.toStringAsFixed(0)}',
        icon: Icons.currency_rupee_rounded,
        color: AppColors.success,
        subtitle: 'Current month paid',
      ),
      StatCard(
        title: 'Total Revenue',
        value: '₹${admin.totalRevenue.toStringAsFixed(0)}',
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.warning,
        subtitle: 'All-time collections',
      ),
    ];
  }

  Widget _buildManagementGrid(
    AdminProvider admin,
    ThemeData theme, {
    required int crossAxisCount,
  }) {
    final items = [
      (
        Icons.people_rounded,
        'Member Management',
        '${admin.members.length} members',
        AppColors.info,
        const MemberManagementScreen(),
      ),
      (
        Icons.sports_rounded,
        'Trainer Management',
        '${admin.trainers.length} trainers',
        AppColors.accent,
        const TrainerManagementScreen(),
      ),
      (
        Icons.payments_rounded,
        'Fee Management',
        '${admin.fees.length} records',
        AppColors.success,
        const FeeManagementScreen(),
      ),
      (
        Icons.card_membership_rounded,
        'Membership Plans',
        '${admin.plans.length} plans',
        AppColors.primary,
        const PlanManagementScreen(),
      ),
      (
        Icons.local_offer_rounded,
        'Promotions',
        '${admin.promotions.length} active',
        AppColors.warning,
        const PromotionManagementScreen(),
      ),
      (
        Icons.emoji_events_rounded,
        'Challenges',
        '${admin.challenges.length} running',
        Colors.purple,
        const ChallengeManagementScreen(),
      ),
      (
        Icons.fitness_center_rounded,
        'Exercise Library',
        '${admin.exercises.length} exercises',
        Colors.teal,
        const ExerciseManagementScreen(),
      ),
      (
        Icons.notifications_active_rounded,
        'Notifications',
        'Broadcast to members',
        Colors.orange,
        const NotificationManagementScreen(),
      ),
      (
        Icons.mail_rounded,
        'Contact Enquiries',
        '${admin.contacts.where((c) => !c.isRead).length} new',
        AppColors.error,
        const ContactInquiriesScreen(),
      ),
      (
        Icons.bar_chart_rounded,
        'Analytics & Reports',
        'Revenue & check-in graphs',
        Colors.cyan,
        const AnalyticsReportsScreen(),
      ),
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map(
            (e) => FeatureCard(
              icon: e.$1,
              title: e.$2,
              subtitle: e.$3,
              color: e.$4,
              onTap: () => _navigate(e.$5),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AdminProvider admin,
    AuthProvider auth,
    ThemeData theme,
  ) {
    return Drawer(
      child: Column(
        children: [
          RoleDrawerHeader(
            title: auth.currentUser?.name ?? 'Admin',
            subtitle: 'Master Administrator',
            badgeText: 'ADMIN PORTAL',
            badgeColor: theme.colorScheme.primary,
            imagePath: 'assets/admin/img1.jpg',
            avatarText: auth.currentUser?.name ?? 'Admin',
            email: auth.currentUser?.email,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(
                  context,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  () => Navigator.pop(context),
                ),
                _drawerItem(
                  context,
                  Icons.people_rounded,
                  'Member Management',
                  () => _navigateFromDrawer(
                    context,
                    const MemberManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.sports_rounded,
                  'Trainer Management',
                  () => _navigateFromDrawer(
                    context,
                    const TrainerManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.payments_rounded,
                  'Fee Management',
                  () =>
                      _navigateFromDrawer(context, const FeeManagementScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.card_membership_rounded,
                  'Membership Plans',
                  () => _navigateFromDrawer(
                    context,
                    const PlanManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.local_offer_rounded,
                  'Promotions & Discounts',
                  () => _navigateFromDrawer(
                    context,
                    const PromotionManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.emoji_events_rounded,
                  'Fitness Challenges',
                  () => _navigateFromDrawer(
                    context,
                    const ChallengeManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.fitness_center_rounded,
                  'Exercise Library',
                  () => _navigateFromDrawer(
                    context,
                    const ExerciseManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.notifications_active_rounded,
                  'Notifications',
                  () => _navigateFromDrawer(
                    context,
                    const NotificationManagementScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.mail_rounded,
                  'Contact Enquiries',
                  () => _navigateFromDrawer(
                    context,
                    const ContactInquiriesScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.bar_chart_rounded,
                  'Analytics & Reports',
                  () => _navigateFromDrawer(
                    context,
                    const AnalyticsReportsScreen(),
                  ),
                ),
                const Divider(),
                _drawerItem(
                  context,
                  Icons.palette_outlined,
                  'Theme & Appearance',
                  () =>
                      _navigateFromDrawer(context, const ThemeSettingsScreen()),
                ),
                _drawerItem(context, Icons.logout_rounded, 'Sign Out', () {
                  Navigator.pop(context);
                  auth.logout();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateFromDrawer(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
