import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/public_provider.dart';
import '../../auth/screens/register_screen.dart';

class PublicPlansScreen extends StatelessWidget {
  final bool isStandalone;
  const PublicPlansScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    final publicProvider = Provider.of<PublicProvider>(context);
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> fallbackPlans = [
      {
        'name': 'Standard Monthly Pass',
        'price': 1499.0,
        'duration': '1 Month',
        'description': 'Full access to gym equipment, locker facilities, and cardio theater.',
        'features': [
          'Full free weights and machine access',
          'Access during all operating hours',
          'Locker room & hot shower amenities',
          'Complimentary body composition scan',
        ],
        'isPopular': false,
      },
      {
        'name': 'Gold Quarter Pro',
        'price': 3999.0,
        'duration': '3 Months',
        'description': 'Our most popular membership with unlimited group classes and guest privileges.',
        'features': [
          'All Standard access amenities',
          'Unlimited functional HIIT group classes',
          '1 Free 1-on-1 personal training session',
          'Custom diet macro blueprint',
          'Guest pass privilege (1 per month)',
        ],
        'isPopular': true,
      },
      {
        'name': 'Annual Elite Athlete',
        'price': 12999.0,
        'duration': '12 Months',
        'description': 'Best value annual commitment for dedicated athletes seeking top transformation.',
        'features': [
          'Complete gym & studio access for 365 days',
          'Personal trainer check-ins every month',
          'Monthly DEXA body fat tracking',
          'Sauna and recovery lounge unlimited access',
          'Complimentary Gym Pro performance tee & shaker',
        ],
        'isPopular': false,
      },
    ];

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
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.card_membership,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Transparent, No-Contract Pricing',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the membership plan that matches your fitness trajectory. All plans include full floor access with no hidden cancellation fees.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (publicProvider.plans.isNotEmpty)
          ...publicProvider.plans.map((p) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '₹${p.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Duration: ${p.durationValue} ${p.durationUnit.toLowerCase()}(s)',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (p.extraFeatures.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.extraFeatures,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Enroll in this Plan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
        else
          ...fallbackPlans.map((p) {
            final isPopular = p['isPopular'] as bool;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isPopular
                    ? const BorderSide(color: AppColors.primary, width: 2)
                    : BorderSide(color: theme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPopular)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p['name'] as String,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '₹${(p['price'] as double).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Billed for ${p['duration']}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p['description'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const Divider(height: 24),
                    ...((p['features'] as List<String>).map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: isPopular
                            ? null
                            : ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                              ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Choose This Plan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );

    if (isStandalone) {
      return Scaffold(
        appBar: AppBar(title: const Text('Membership Plans')),
        body: content,
      );
    }

    return content;
  }
}
