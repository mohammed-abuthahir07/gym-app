import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class GalleryItem {
  final String title;
  final String category;
  final String imagePath;
  final String description;

  const GalleryItem({
    required this.title,
    required this.category,
    required this.imagePath,
    required this.description,
  });
}

class PublicGalleryScreen extends StatefulWidget {
  final bool isStandalone;
  const PublicGalleryScreen({super.key, this.isStandalone = false});

  @override
  State<PublicGalleryScreen> createState() => _PublicGalleryScreenState();
}

class _PublicGalleryScreenState extends State<PublicGalleryScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Facility',
    'Strength',
    'Cardio',
    'Group Workouts',
    'Trainers',
  ];

  final List<GalleryItem> _items = const [
    GalleryItem(
      title: 'Olympic Weightlifting Zone',
      category: 'Strength',
      imagePath: 'assets/public/img.jpg',
      description:
          'Olympic barbells, bumper plates, and competition-grade power racks.',
    ),
    GalleryItem(
      title: 'Free Weight Floor & Dumbbells',
      category: 'Strength',
      imagePath: 'assets/images/Free Weight Floor.png',
      description: 'Extensive dumbbell racks from 2.5kg to 60kg with adjustable benches.',
    ),
    GalleryItem(
      title: 'Cardio & HIIT Studio',
      category: 'Cardio',
      imagePath: 'assets/images/cardio.png',
      description: 'Curved treadmills, assault bikes, rowing machines, and stair climbers.',
    ),
    GalleryItem(
      title: 'High-Intensity Group Training',
      category: 'Group Workouts',
      imagePath: 'assets/images/groupworkout.jpg',
      description: 'Dynamic group training sessions focused on fat loss, stamina, and agility.',
    ),
    GalleryItem(
      title: 'Certified Personal Coaching',
      category: 'Trainers',
      imagePath: 'assets/images/ladyTrainer.jpg',
      description: 'One-on-one tailored coaching with personalized form and diet monitoring.',
    ),
    GalleryItem(
      title: 'Modern Gym Floor & Machines',
      category: 'Facility',
      imagePath: 'assets/public/img2.jpg',
      description: 'Spacious climate-controlled floor with state-of-the-art selectorized machines.',
    ),
    GalleryItem(
      title: 'Core & Functional Training Area',
      category: 'Strength',
      imagePath: 'assets/public/img3.jpg',
      description: 'Turf track, kettlebells, medicine balls, and plyometric boxes for athletic performance.',
    ),
    GalleryItem(
      title: 'Group Fitness Community',
      category: 'Group Workouts',
      imagePath: 'assets/images/group.png',
      description: 'Engaging, supportive group fitness community motivating each other daily.',
    ),
    GalleryItem(
      title: 'Recovery & Locker Facilities',
      category: 'Facility',
      imagePath: 'assets/public/img4.jpg',
      description:
          'Clean modern locker rooms, hot showers, sauna, and supplement bar.',
    ),
    GalleryItem(
      title: 'Elite Athletic Conditioning',
      category: 'Trainers',
      imagePath: 'assets/images/workout.jpg',
      description: 'Advanced sports-specific training for competitive athletes and bodybuilders.',
    ),
  ];

  List<GalleryItem> get _filteredItems {
    if (_selectedCategory == 'All') return _items;
    return _items.where((i) => i.category == _selectedCategory).toList();
  }

  void _showImageLightbox(GalleryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 250,
                  color: Colors.black54,
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Grid of images
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemCount: _filteredItems.length,
            itemBuilder: (ctx, idx) {
              final item = _filteredItems[idx];
              return InkWell(
                onTap: () => _showImageLightbox(item),
                borderRadius: BorderRadius.circular(14),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white30,
                            size: 36,
                          ),
                        ),
                      ),
                      Container(
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
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gym Gallery')),
        body: content,
      );
    }

    return content;
  }
}
