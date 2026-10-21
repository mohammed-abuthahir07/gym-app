import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/image_slider.dart';
import '../../../shared/widgets/role_drawer_header.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/empty_state.dart';
import 'member_profile_screen.dart';
import 'member_workout_plans_screen.dart';
import 'member_diet_plans_screen.dart';
import 'member_progress_screen.dart';
import 'member_cheat_days_screen.dart';
import 'member_classes_screen.dart';
import 'member_exercises_screen.dart';
import 'member_challenges_screen.dart';
import 'member_fees_screen.dart';
import 'member_chat_screen.dart';
import 'member_notifications_screen.dart';
import '../../settings/screens/theme_settings_screen.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  final List<String> _memberImages = const [
    'assets/member/img.jpg',
    'assets/member/img2.jpg',
    'assets/member/img3.jpg',
    'assets/member/img4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<MemberProvider>(
          context,
          listen: false,
        ).loadMemberData(auth.currentUser!.id, auth.currentUser!.trainerId);
      }
    });
  }

  void _navigate(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'My Fitness Hub',
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                tooltip: 'Notifications',
                onPressed: () => _navigate(const MemberNotificationsScreen()),
              ),
              if (member.notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${member.notificationCount}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Sign Out',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, member, auth, user, theme),
      body: member.isLoading
          ? const LoadingView(message: 'Loading your fitness metrics...')
          : (member.errorMessage != null &&
                member.profile == null &&
                member.workoutPlans.isEmpty)
          ? EmptyState(
              title: 'Unable to Load Fitness Hub',
              message: member.errorMessage!,
              icon: Icons.cloud_off_rounded,
              action: ElevatedButton.icon(
                onPressed: () {
                  if (user != null) {
                    member.loadMemberData(user.id, user.trainerId);
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await member.loadMemberData(user.id, user.trainerId);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header with responsive ImageSlider and well-spaced card
                    ImageSlider(
                      imagePaths: _memberImages,
                      height: 255,
                      overlayContent: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
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
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: AppColors.primary,
                                          child: Text(
                                            user?.name.isNotEmpty == true
                                                ? user!.name[0].toUpperCase()
                                                : 'M',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hello, ${user?.name ?? 'Member'} 💪',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              user?.fitnessGoal ??
                                                  'Improve general fitness',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        tooltip: 'Edit Profile',
                                        onPressed: () => _navigate(
                                          const MemberProfileScreen(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (user?.trainerName != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.sports,
                                            size: 13,
                                            color: AppColors.accent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Trainer: ${user!.trainerName}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                          _buildSectionLabel('Your Progress Overview', theme),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              StatCard(
                                title: 'Gym Check-in Days',
                                value: '${member.checkInDays}',
                                icon: Icons.check_circle_rounded,
                                color: AppColors.success,
                                subtitle: 'Total gym attendance',
                              ),
                              StatCard(
                                title: 'Month Cheat Meals',
                                value: '${member.currentMonthCheatCount}',
                                icon: Icons.fastfood_rounded,
                                color: AppColors.warning,
                                subtitle: 'Current month count',
                              ),
                              StatCard(
                                title: 'Workout Plans',
                                value: '${member.workoutPlansCount}',
                                icon: Icons.fitness_center_rounded,
                                color: AppColors.primary,
                                subtitle: 'Assigned programs',
                              ),
                              StatCard(
                                title: 'Fee Status',
                                value: member.currentMonthPaymentStatus,
                                icon: Icons.payment_rounded,
                                color:
                                    member.currentMonthPaymentStatus == 'PAID'
                                    ? AppColors.success
                                    : AppColors.error,
                                subtitle: 'Current month due',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Today's Workouts
                          if (member.todayWorkouts.isNotEmpty) ...[
                            _buildSectionLabel("Today's Workouts", theme),
                            const SizedBox(height: 10),
                            ...member.todayWorkouts.map(
                              (ex) =>
                                  _buildWorkoutTile(ex, member, user, theme),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Feature grid
                          _buildSectionLabel('Member Features', theme),
                          const SizedBox(height: 12),
                          _buildFeatureGrid(user, member, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String text, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
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

  Widget _buildWorkoutTile(
    dynamic ex,
    MemberProvider member,
    dynamic user,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          ex.exerciseName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${ex.sets} sets × ${ex.reps} reps • ${ex.durationMinutes} mins',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
          onPressed: () async {
            if (user != null) {
              try {
                await member.completeWorkoutExercise(
                  memberId: user.id,
                  workoutPlanExerciseId: ex.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked workout as completed for today!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Done'),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(
    dynamic user,
    MemberProvider member,
    ThemeData theme,
  ) {
    final items = [
      (
        Icons.fitness_center_rounded,
        'Workout Plans',
        'Routines, reps & sets',
        AppColors.primary,
        const MemberWorkoutPlansScreen(),
      ),
      (
        Icons.restaurant_rounded,
        'Diet & Nutrition',
        'Meal plans & macros',
        AppColors.success,
        const MemberDietPlansScreen(),
      ),
      (
        Icons.show_chart_rounded,
        'Progress Tracking',
        'Weight, body fat & measurements',
        AppColors.info,
        const MemberProgressScreen(),
      ),
      (
        Icons.fastfood_rounded,
        'Cheat-Day Logger',
        'Log & monitor treat meals',
        AppColors.warning,
        const MemberCheatDaysScreen(),
      ),
      (
        Icons.calendar_month_rounded,
        'Class Schedules',
        'Group & personal sessions',
        Colors.purple,
        const MemberClassesScreen(),
      ),
      (
        Icons.emoji_events_rounded,
        'Fitness Challenges',
        'Compete & earn rewards',
        Colors.orange,
        const MemberChallengesScreen(),
      ),
      (
        Icons.library_books_rounded,
        'Exercise Library',
        'Browse all gym exercises',
        Colors.teal,
        const MemberExercisesScreen(),
      ),
      (
        Icons.payments_rounded,
        'Fee & Payments',
        'Review paid invoices',
        AppColors.error,
        const MemberFeesScreen(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...items.map(
          (e) => FeatureCard(
            icon: e.$1,
            title: e.$2,
            subtitle: e.$3,
            color: e.$4,
            onTap: () => _navigate(e.$5),
          ),
        ),
        FeatureCard(
          icon: Icons.chat_rounded,
          title: 'Chat with Trainer',
          subtitle: user?.trainerName != null
              ? 'Chat with Coach ${user!.trainerName}'
              : 'Awaiting trainer assignment',
          color: Colors.indigo,
          onTap: () {
            if (user?.trainerId != null) {
              _navigate(const MemberChatScreen());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No trainer assigned yet. Please contact administration.',
                  ),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    MemberProvider member,
    AuthProvider auth,
    dynamic user,
    ThemeData theme,
  ) {
    return Drawer(
      child: Column(
        children: [
          // Premium responsive drawer header with status bar safety
          RoleDrawerHeader(
            title: user?.name ?? 'Member',
            subtitle: user?.fitnessGoal ?? 'General Fitness',
            badgeText: 'MEMBER PORTAL',
            badgeColor: AppColors.primary,
            imagePath: 'assets/member/img.jpg',
            avatarText: user?.name,
            email: user?.email,
            onProfileTap: () =>
                _navFromDrawer(context, const MemberProfileScreen()),
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
                  Icons.person_rounded,
                  'My Profile',
                  () => _navFromDrawer(context, const MemberProfileScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.fitness_center_rounded,
                  'Workout Plans',
                  () =>
                      _navFromDrawer(context, const MemberWorkoutPlansScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.restaurant_rounded,
                  'Diet & Nutrition',
                  () => _navFromDrawer(context, const MemberDietPlansScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.show_chart_rounded,
                  'Progress Tracking',
                  () => _navFromDrawer(context, const MemberProgressScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.fastfood_rounded,
                  'Cheat-Day Logger',
                  () => _navFromDrawer(context, const MemberCheatDaysScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.calendar_month_rounded,
                  'Class Schedules',
                  () => _navFromDrawer(context, const MemberClassesScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.emoji_events_rounded,
                  'Fitness Challenges',
                  () => _navFromDrawer(context, const MemberChallengesScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.library_books_rounded,
                  'Exercise Library',
                  () => _navFromDrawer(context, const MemberExercisesScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.payments_rounded,
                  'Fee & Payments',
                  () => _navFromDrawer(context, const MemberFeesScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.chat_rounded,
                  'Chat with Trainer',
                  () {
                    Navigator.pop(context);
                    if (user?.trainerId != null) {
                      _navigate(const MemberChatScreen());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No trainer assigned yet.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  },
                ),
                _drawerItem(
                  context,
                  Icons.notifications_rounded,
                  'Notifications',
                  () => _navFromDrawer(
                    context,
                    const MemberNotificationsScreen(),
                  ),
                ),
                const Divider(),
                _drawerItem(
                  context,
                  Icons.palette_outlined,
                  'Theme & Appearance',
                  () => _navFromDrawer(context, const ThemeSettingsScreen()),
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

  void _navFromDrawer(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
