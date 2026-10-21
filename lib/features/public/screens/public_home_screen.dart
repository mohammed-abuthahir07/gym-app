import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/public_provider.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/empty_state.dart';
import 'contact_screen.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PublicProvider>(context, listen: false).loadPublicData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicProvider = Provider.of<PublicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Gym'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_mail_outlined),
            tooltip: 'Contact Us',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Plans'),
            Tab(text: 'Offers'),
            Tab(text: 'Trainers'),
            Tab(text: 'Tips & Content'),
          ],
        ),
      ),
      body: publicProvider.isLoading
          ? const LoadingView(message: 'Loading gym highlights...')
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Membership Plans
                publicProvider.plans.isEmpty
                    ? const EmptyState(
                        title: 'No Plans Available',
                        message: 'Membership plans will appear here once published by administration.',
                        icon: Icons.card_membership_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: publicProvider.plans.length,
                        itemBuilder: (ctx, idx) {
                          final p = publicProvider.plans[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '₹${p.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          'Duration: ${p.durationValue} ${p.durationUnit.toLowerCase()}(s)',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor: AppColors.surface,
                                      ),
                                      if (p.extraFeatures.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            p.extraFeatures,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // 2. Promotions
                publicProvider.promotions.isEmpty
                    ? const EmptyState(
                        title: 'No Active Promotions',
                        message: 'Special promotional offers and seasonal discounts will show here.',
                        icon: Icons.local_offer_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: publicProvider.promotions.length,
                        itemBuilder: (ctx, idx) {
                          final promo = publicProvider.promotions[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.percent, color: Colors.white),
                              ),
                              title: Text(
                                promo.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(promo.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Code: ${promo.code} • Valid till ${promo.endDate}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                promo.discountType == 'PERCENTAGE'
                                    ? '${promo.discount.toStringAsFixed(0)}% OFF'
                                    : '₹${promo.discount.toStringAsFixed(0)} OFF',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                // 3. Trainers
                publicProvider.trainers.isEmpty
                    ? const EmptyState(
                        title: 'Trainers Directory',
                        message: 'Certified gym trainers and coaches will be listed here.',
                        icon: Icons.people_outline,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: publicProvider.trainers.length,
                        itemBuilder: (ctx, idx) {
                          final t = publicProvider.trainers[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.accent,
                                child: Text(
                                  t.name.isNotEmpty
                                      ? t.name[0].toUpperCase()
                                      : 'T',
                                ),
                              ),
                              title: Text(
                                t.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(t.email),
                              trailing: const Icon(
                                Icons.verified,
                                color: AppColors.info,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),

                // 4. Content / Tips
                publicProvider.contents.isEmpty
                    ? const EmptyState(
                        title: 'No Tips Available',
                        message:
                            'Fitness and nutrition articles will appear here.',
                        icon: Icons.article_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: publicProvider.contents.length,
                        itemBuilder: (ctx, idx) {
                          final c = publicProvider.contents[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    c.description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactScreen()),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Enquire Now'),
      ),
    );
  }
}
