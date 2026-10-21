import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/screens/register_screen.dart';

class PublicAboutScreen extends StatelessWidget {
  final bool isStandalone;
  const PublicAboutScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero image banner
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                'assets/public/img2.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) =>
                    Container(height: 200, color: AppColors.surface),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ABOUT PULSE & POWER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Empowering Lifelong Fitness & Strength',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Mission & Philosophy
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Our Core Mission',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'At Pulse & Power, we believe true fitness is a holistic journey, not an intimidating destination. We are committed to providing premium equipment, science-backed workout methodologies, certified trainer guidance, and a welcoming community atmosphere where individuals of all skill levels can break plateaus.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3 Pillars
        const Text(
          'What Sets Us Apart',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPillarCard(
          icon: Icons.fitness_center_rounded,
          title: 'Precision Equipment',
          desc: 'Competition-grade Olympic bars, calibrated weight plates, selectorized machines, and specialized isolation stations.',
          accentColor: AppColors.info,
        ),
        const SizedBox(height: 10),
        _buildPillarCard(
          icon: Icons.sports_rounded,
          title: 'Certified Personal Trainers',
          desc: 'Qualified coaching experts who craft custom workout progressions, teach safe lifting form, and monitor diet macros.',
          accentColor: AppColors.accent,
        ),
        const SizedBox(height: 10),
        _buildPillarCard(
          icon: Icons.people_outline_rounded,
          title: 'Supportive Fitness Community',
          desc: 'Encouraging atmosphere where seasoned lifters and newcomers train alongside each other in an ego-free zone.',
          accentColor: AppColors.success,
        ),
        const SizedBox(height: 20),

        // Facility Highlights Gallery Cards
        const Text(
          'Our Facility Highlights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFacilityThumb(
                'Free Weight Zone',
                'assets/images/Free Weight Floor.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFacilityThumb(
                'Cardio Theater',
                'assets/images/cardio.png',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFacilityThumb(
                'HIIT Group Studio',
                'assets/images/groupworkout.jpg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFacilityThumb(
                'Recovery & Saunas',
                'assets/public/img4.jpg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // CTA
        Card(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.primary, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Ready to Begin Your Fitness Transformation?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your fitness journey today. Experience world-class coaching and top-tier facilities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Join Pulse & Power Now'),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isStandalone) {
      return Scaffold(
        appBar: AppBar(title: const Text('About Pulse & Power')),
        body: content,
      );
    }

    return content;
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color accentColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityThumb(String title, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            height: 110,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) =>
                Container(height: 110, color: AppColors.surface),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
