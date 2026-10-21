import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/image_slider.dart';
import '../../../shared/widgets/role_drawer_header.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../settings/screens/theme_settings_screen.dart';
import 'assigned_members_screen.dart';
import 'trainer_workout_plans_screen.dart';
import 'trainer_diet_plans_screen.dart';
import 'trainer_schedules_screen.dart';
import 'trainer_cheat_days_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final List<String> _trainerImages = const [
    'assets/trainer/img1.jpg',
    'assets/trainer/img2.jpg',
    'assets/trainer/img3.jpg',
    'assets/trainer/img4.jpg',
    'assets/trainer/img5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<TrainerProvider>(
          context,
          listen: false,
        ).loadTrainerData(auth.currentUser!.id);
      }
    });
  }

  void _navigate(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
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
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sports, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Trainer Hub',
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
            onPressed: () {
              if (auth.currentUser != null) {
                trainer.loadTrainerData(auth.currentUser!.id);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Sign Out',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, trainer, auth, theme),
      body: trainer.isLoading
          ? const LoadingView(message: 'Loading trainer dashboard...')
          : trainer.errorMessage != null
          ? EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Could Not Load Data',
              message: trainer.errorMessage!,
              action: ElevatedButton.icon(
                onPressed: () {
                  if (auth.currentUser != null) {
                    trainer.loadTrainerData(auth.currentUser!.id);
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (auth.currentUser != null) {
                  await trainer.loadTrainerData(auth.currentUser!.id);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trainer image slider with overlay card
                    ImageSlider(
                      imagePaths: _trainerImages,
                      height: 250,
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
                                      'TRAINER PORTAL',
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
                                    'Coach ${auth.currentUser?.name ?? 'Trainer'} 🏋️',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    auth.currentUser?.email ??
                                        'Certified Fitness Trainer',
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
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Your Stats', theme),
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
                                title: 'Assigned Members',
                                value: '${trainer.assignedMembersCount}',
                                icon: Icons.people_rounded,
                                color: AppColors.info,
                                subtitle: 'Clients under guidance',
                              ),
                              StatCard(
                                title: "Today's Workouts",
                                value: '${trainer.todayWorkoutsCount}',
                                icon: Icons.fitness_center_rounded,
                                color: theme.colorScheme.primary,
                                subtitle: 'Scheduled exercises today',
                              ),
                              StatCard(
                                title: 'Diet Plans',
                                value: '${trainer.dietPlansCount}',
                                icon: Icons.restaurant_menu_rounded,
                                color: AppColors.success,
                                subtitle: 'Assigned meal plans',
                              ),
                              StatCard(
                                title: 'Class Schedules',
                                value: '${trainer.schedules.length}',
                                icon: Icons.calendar_today_rounded,
                                color: AppColors.warning,
                                subtitle: 'Upcoming classes',
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          _buildSectionLabel('Coaching Tools', theme),
                          const SizedBox(height: 12),
                          _buildToolsGrid(theme),
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

  Widget _buildToolsGrid(ThemeData theme) {
    final tools = [
      (
        Icons.people_rounded,
        'Assigned Members',
        'View profiles & client chat',
        AppColors.info,
        const AssignedMembersScreen(),
      ),
      (
        Icons.fitness_center_rounded,
        'Workout Plans',
        'Create & assign routines',
        theme.colorScheme.primary,
        const TrainerWorkoutPlansScreen(),
      ),
      (
        Icons.restaurant_rounded,
        'Diet & Nutrition',
        'Assign calorie & meal plans',
        AppColors.success,
        const TrainerDietPlansScreen(),
      ),
      (
        Icons.calendar_month_rounded,
        'Class Schedules',
        'Schedule HIIT & cardio sessions',
        AppColors.warning,
        const TrainerSchedulesScreen(),
      ),
      (
        Icons.fastfood_rounded,
        'Cheat-Day Logs',
        'Review member cheat meals',
        AppColors.error,
        const TrainerCheatDaysScreen(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tools
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
    TrainerProvider trainer,
    AuthProvider auth,
    ThemeData theme,
  ) {
    return Drawer(
      child: Column(
        children: [
          RoleDrawerHeader(
            title: 'Coach ${auth.currentUser?.name ?? 'Trainer'}',
            subtitle: 'Certified Fitness Coach',
            badgeText: 'TRAINER PORTAL',
            badgeColor: theme.colorScheme.primary,
            imagePath: 'assets/trainer/img1.jpg',
            avatarText: auth.currentUser?.name ?? 'Trainer',
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
                  'Assigned Members',
                  () => _navFromDrawer(context, const AssignedMembersScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.fitness_center_rounded,
                  'Workout Plans',
                  () => _navFromDrawer(
                    context,
                    const TrainerWorkoutPlansScreen(),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.restaurant_rounded,
                  'Diet & Nutrition Plans',
                  () => _navFromDrawer(context, const TrainerDietPlansScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.calendar_month_rounded,
                  'Class Schedules',
                  () => _navFromDrawer(context, const TrainerSchedulesScreen()),
                ),
                _drawerItem(
                  context,
                  Icons.fastfood_rounded,
                  'Cheat-Day Logs',
                  () => _navFromDrawer(context, const TrainerCheatDaysScreen()),
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

