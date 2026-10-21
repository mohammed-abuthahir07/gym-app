import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/image_slider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../widgets/contact_enquiry_dialog.dart';

class PublicHomeTab extends StatefulWidget {
  final Function(int pageIndex) onNavigatePage;

  const PublicHomeTab({super.key, required this.onNavigatePage});

  @override
  State<PublicHomeTab> createState() => _PublicHomeTabState();
}

class _PublicHomeTabState extends State<PublicHomeTab> {
  static const String _popupKey = 'contact_popup_seen';
  bool _popupCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowFirstVisitPopup();
    });
  }

  Future<void> _checkAndShowFirstVisitPopup() async {
    if (_popupCheckDone || !mounted) return;
    _popupCheckDone = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadySeen = prefs.getBool(_popupKey) ?? false;
      if (!alreadySeen && mounted) {
        // Allow the interface to smoothly finish rendering first
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;

        // Display modal popup
        await ContactEnquiryDialog.show(context);

        // Mark as seen ONLY after popup has been shown and user dismissed or completed it
        await prefs.setBool(_popupKey, true);
      }
    } catch (_) {}
  }

  void _openContactDialog() {
    ContactEnquiryDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<String> heroImages = const [
      'assets/public/img.jpg',
      'assets/public/img2.jpg',
      'assets/public/img3.jpg',
      'assets/public/img4.jpg',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. HERO SLIDER
          ImageSlider(
            imagePaths: heroImages,
            height: 380,
            autoPlayDuration: const Duration(seconds: 4),
            overlayContent: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PULSE & POWER FITNESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BUILD STRENGTH.\nTRANSFORM LIFE.',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Premier equipment, custom workout regimens, macro-balanced nutrition, and world-class certified coaching.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Join Now'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            widget.onNavigatePage(2), // Membership Plans
                        child: const Text('Explore Plans'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. GYM HIGHLIGHTS
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  badge: 'WHY TRAIN WITH US',
                  title: 'Engineered for Peak Performance',
                  theme: theme,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildHighlightCard(
                      icon: Icons.fitness_center,
                      title: 'Modern Equipment',
                      desc: 'Competition barbells, selectorized machines & dumbbells to 60kg.',
                      color: AppColors.info,
                    ),
                    _buildHighlightCard(
                      icon: Icons.sports,
                      title: 'Certified Trainers',
                      desc: 'Dedicated coaches guiding form, reps, and progression.',
                      color: AppColors.accent,
                    ),
                    _buildHighlightCard(
                      icon: Icons.restaurant_menu,
                      title: 'Nutrition Blueprint',
                      desc: 'Calorie and macro plans tailored to body composition goals.',
                      color: AppColors.success,
                    ),
                    _buildHighlightCard(
                      icon: Icons.groups_rounded,
                      title: 'Supportive Tribe',
                      desc: 'Motivating group workouts and monthly fitness challenges.',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. FEATURED PROGRAMS
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  badge: 'TRAINING DISCIPLINES',
                  title: 'Featured Fitness Programs',
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildProgramCard(
                  title: 'Hypertrophy & Muscle Building',
                  desc: 'Structured periodization designed to build dense lean muscle with compound lifting and isolation exercises.',
                  imagePath: 'assets/images/workout.jpg',
                ),
                const SizedBox(height: 14),
                _buildProgramCard(
                  title: 'Functional HIIT & Fat Loss',
                  desc: 'High-energy interval conditioning for rapid caloric expenditure, speed, agility, and cardiovascular endurance.',
                  imagePath: 'assets/images/groupworkout.jpg',
                ),
                const SizedBox(height: 14),
                _buildProgramCard(
                  title: 'Powerlifting & Heavy Strength',
                  desc: 'Master the squat, bench press, and deadlift with competition-certified barbell techniques and safety spotting.',
                  imagePath: 'assets/images/Free Weight Floor.png',
                ),
              ],
            ),
          ),

          // 4. MEMBERSHIP PLANS PREVIEW
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSectionHeader(
                        badge: 'MEMBERSHIP ACCESS',
                        title: 'Flexible Plans for Everyone',
                        theme: theme,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(2), // Plans tab
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Gold 3-Month Transformation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹3,999',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Includes unlimited access to free weights, cardio theater, group classes, sauna, and a personalized diet blueprint.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Chip(
                              label: Text(
                                'Duration: 3 Months',
                                style: TextStyle(fontSize: 11),
                              ),
                              backgroundColor: AppColors.surface,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text('Enroll Now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. PROMOTIONAL BANNER PREVIEW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: InkWell(
              onTap: () => widget.onNavigatePage(3), // Promotions tab
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFE50914)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.percent_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPECIAL PROMO DEALS ACTIVE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get 25% Off Annual Plans',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap to view coupon codes & seasonal deals',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 6. GALLERY PREVIEW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSectionHeader(
                        badge: 'OUR FACILITY',
                        title: 'Inside Pulse & Power',
                        theme: theme,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(4), // Gallery tab
                      child: const Text('View Gallery'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/public/img.jpg',
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              Container(height: 130, color: AppColors.surface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/public/img2.jpg',
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              Container(height: 130, color: AppColors.surface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/public/img3.jpg',
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              Container(height: 130, color: AppColors.surface),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 7. TRAINERS PREVIEW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSectionHeader(
                        badge: 'EXPERT COACHING',
                        title: 'Certified Personal Trainers',
                        theme: theme,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(5), // Trainers tab
                      child: const Text('Meet Coaches'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTrainerThumb(
                        name: 'Sarah Jenkins',
                        role: 'Functional Coach',
                        imagePath: 'assets/images/ladyTrainer.jpg',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTrainerThumb(
                        name: 'Ahmed Khan',
                        role: 'Strength Coach',
                        imagePath: 'assets/trainer/img1.jpg',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 8. HOURS & LOCATION INFO
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  badge: 'VISIT US',
                  title: 'Location & Operating Hours',
                  theme: theme,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Pulse & Power Fitness Complex, 4th Floor, Sports Hub, Main Avenue',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Mon - Sat: 06:00 AM - 10:00 PM  |  Sunday: 07:00 AM - 01:00 PM',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openContactDialog,
                    icon: const Icon(Icons.mail_outline_rounded, size: 18),
                    label: const Text('Send Message / Inquiry'),
                  ),
                ),
              ],
            ),
          ),

          // 9. FOOTER
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PULSE & POWER FITNESS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unleash your strength. Premier equipment, customized workout regimens, nutrition meal plans, and world-class certified coaching.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => widget.onNavigatePage(1),
                      child: const Text(
                        'About Us',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(2),
                      child: const Text(
                        'Plans',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(3),
                      child: const Text(
                        'Promotions',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(4),
                      child: const Text(
                        'Gallery',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigatePage(5),
                      child: const Text(
                        'Trainers',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: _openContactDialog,
                      child: const Text(
                        'Contact Us',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Member / Staff Sign In',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '© 2026 Pulse & Power Gym Management System. All rights reserved.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String badge,
    required String title,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          badge,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard({
    required String title,
    required String desc,
    required String imagePath,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) =>
                Container(height: 160, color: Colors.black26),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerThumb({
    required String name,
    required String role,
    required String imagePath,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, stack) =>
                Container(height: 130, color: AppColors.surface),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: const TextStyle(color: AppColors.accent, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
