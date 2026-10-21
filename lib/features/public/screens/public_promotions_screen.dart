import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/public_provider.dart';
import '../../auth/screens/register_screen.dart';

class PublicPromotionsScreen extends StatelessWidget {
  final bool isStandalone;
  const PublicPromotionsScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    final publicProvider = Provider.of<PublicProvider>(context);
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> fallbackOffers = [
      {
        'title': 'New Member Welcome Discount',
        'code': 'JOINPRO25',
        'discount': '25% OFF',
        'desc': 'Get 25% off your first 3-month or annual membership when signing up this week.',
        'expiry': 'Valid through end of month',
        'image': 'assets/public/img.jpg',
      },
      {
        'title': 'Seasonal Transformation Package',
        'code': 'SHRED30',
        'discount': '₹1,500 OFF',
        'desc': 'Includes 12 weeks of training, customized meal nutrition blueprint, and coach check-ins.',
        'expiry': 'Limited to first 50 signups',
        'image': 'assets/images/sixpacks.jpg',
      },
      {
        'title': 'Student & Corporate Wellness Pass',
        'code': 'FITCAMPUS',
        'discount': '20% OFF',
        'desc': 'Special concession with valid college or workplace identity card. Full day access included.',
        'expiry': 'Ongoing season offer',
        'image': 'assets/images/groupworkout.jpg',
      },
      {
        'title': 'Personal Training Starter Bundle',
        'code': 'COACH50',
        'discount': '30% OFF',
        'desc': 'Book 10 private training sessions with our master trainers and receive free body fat analysis.',
        'expiry': 'Valid for new clients',
        'image': 'assets/images/ladyTrainer.jpg',
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
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Exclusive Gym Deals & Specials',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Take advantage of current promotional coupon codes. Apply your code during registration or present it at the gym front desk.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (publicProvider.promotions.isNotEmpty)
          ...publicProvider.promotions.map((p) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.discountType == 'PERCENTAGE'
                                ? '${p.discount.toStringAsFixed(0)}% OFF'
                                : '₹${p.discount.toStringAsFixed(0)} OFF',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'PROMO CODE: ${p.code}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          'Valid till ${p.endDate}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                        child: const Text('Claim This Discount'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
        else
          ...fallbackOffers.map((offer) {
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
                        offer['image'] as String,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(height: 150, color: AppColors.surface),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.85),
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
                          children: [
                            Expanded(
                              child: Text(
                                offer['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                offer['discount'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
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
                          offer['desc'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.accent),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    offer['code'] as String,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              offer['expiry'] as String,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
                            child: const Text('Claim Deal & Register'),
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
        appBar: AppBar(title: const Text('Promotions & Special Deals')),
        body: content,
      );
    }

    return content;
  }
}
