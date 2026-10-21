import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/screens/register_screen.dart';

class PublicTrainerInfo {
  final String name;
  final String specialty;
  final String bio;
  final String imagePath;
  final String experience;
  final List<String> certs;

  const PublicTrainerInfo({
    required this.name,
    required this.specialty,
    required this.bio,
    required this.imagePath,
    required this.experience,
    required this.certs,
  });
}

class PublicTrainersScreen extends StatelessWidget {
  final bool isStandalone;
  const PublicTrainersScreen({super.key, this.isStandalone = false});

  final List<PublicTrainerInfo> _trainers = const [
    PublicTrainerInfo(
      name: 'Sarah Jenkins',
      specialty: 'Head Functional & HIIT Coach',
      bio: 'Specializing in full-body functional transformations, athletic agility, and women\'s strength conditioning.',
      imagePath: 'assets/images/ladyTrainer.jpg',
      experience: '7+ Years Experience',
      certs: ['ACE Certified', 'CrossFit L2', 'Sports Nutrition Specialist'],
    ),
    PublicTrainerInfo(
      name: 'Ahmed Khan',
      specialty: 'Master Strength & Hypertrophy Coach',
      bio: 'Expert in progressive powerlifting, bodybuilding prep, and biomechanically sound muscle building regimens.',
      imagePath: 'assets/trainer/img1.jpg',
      experience: '9+ Years Experience',
      certs: [
        'CSCS Certified',
        'ISSA Bodybuilding Specialist',
        'Kinesiology B.S.',
      ],
    ),
    PublicTrainerInfo(
      name: 'Marcus Vance',
      specialty: 'Calisthenics & Olympic Mobility',
      bio: 'Focused on joint longevity, gymnastic strength, bodyweight mastery, and metabolic conditioning.',
      imagePath: 'assets/trainer/img2.jpg',
      experience: '6+ Years Experience',
      certs: ['NASM-CPT', 'FMS Level 2', 'Mobility WOD Certified'],
    ),
    PublicTrainerInfo(
      name: 'Elena Rostova',
      specialty: 'Endurance & Weight Loss Coach',
      bio: 'Passionate about sustainable lifestyle fat loss, marathon conditioning, and macro-based meal structuring.',
      imagePath: 'assets/images/trainer.png',
      experience: '5+ Years Experience',
      certs: [
        'Precision Nutrition L1',
        'ACSM Certified',
        'Spin & Row Instructor',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'World-Class Certified Coaching',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Our coaches create custom training splits, guide daily exercise form, and calculate your target macros for optimal recovery.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ..._trainers.map((t) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      t.imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 200,
                        color: AppColors.surface,
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  t.specialty,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              t.experience,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.bio,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: t.certs.map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.fitness_center, size: 18),
                          label: const Text('Train With This Coach'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );

    if (isStandalone) {
      return Scaffold(
        appBar: AppBar(title: const Text('Certified Gym Coaches')),
        body: content,
      );
    }

    return content;
  }
}
