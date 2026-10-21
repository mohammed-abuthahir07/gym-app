import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/public_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../settings/screens/theme_settings_screen.dart';
import 'public_home_tab.dart';
import 'public_about_screen.dart';
import 'public_plans_screen.dart';
import 'public_promotions_screen.dart';
import 'public_gallery_screen.dart';
import 'public_trainers_screen.dart';
import 'public_contact_screen.dart';

class PublicWebsiteShell extends StatefulWidget {
  final int initialIndex;
  const PublicWebsiteShell({super.key, this.initialIndex = 0});

  @override
  State<PublicWebsiteShell> createState() => _PublicWebsiteShellState();
}

class _PublicWebsiteShellState extends State<PublicWebsiteShell> {
  late int _currentIndex;

  final List<String> _pageTitles = const [
    'Pulse & Power',
    'About Us',
    'Membership Plans',
    'Promotions & Offers',
    'Gym Gallery',
    'Certified Trainers',
    'Contact Us',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PublicProvider>(context, listen: false).loadPublicData();
    });
  }

  void _onSelectPage(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final List<Widget> pages = [
      PublicHomeTab(onNavigatePage: _onSelectPage),
      const PublicAboutScreen(),
      const PublicPlansScreen(),
      const PublicPromotionsScreen(),
      const PublicGalleryScreen(),
      const PublicTrainersScreen(),
      const PublicContactScreen(),
    ];

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
                Icons.fitness_center,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _pageTitles[_currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // On Desktop, display full top nav buttons
          if (isDesktop) ...[
            _topNavBtn('Home', 0),
            _topNavBtn('About', 1),
            _topNavBtn('Plans', 2),
            _topNavBtn('Offers', 3),
            _topNavBtn('Gallery', 4),
            _topNavBtn('Trainers', 5),
            _topNavBtn('Contact', 6),
            const SizedBox(width: 8),
          ],

          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 22),
            tooltip: 'Theme & Appearance',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              'Sign In',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Join Now'),
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : _buildPublicDrawer(context, theme),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) =>
                      setState(() => _currentIndex = idx),
                  extended: true,
                  minExtendedWidth: 200,
                  backgroundColor: theme.colorScheme.surface,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(Icons.info),
                      label: Text('About Us'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.card_membership_outlined),
                      selectedIcon: Icon(Icons.card_membership),
                      label: Text('Plans'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_offer_outlined),
                      selectedIcon: Icon(Icons.local_offer),
                      label: Text('Offers'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.photo_library_outlined),
                      selectedIcon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.sports_outlined),
                      selectedIcon: Icon(Icons.sports),
                      label: Text('Trainers'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.contact_mail_outlined),
                      selectedIcon: Icon(Icons.contact_mail),
                      label: Text('Contact Us'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[_currentIndex]),
              ],
            )
          : pages[_currentIndex],
    );
  }

  Widget _topNavBtn(String title, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => setState(() => _currentIndex = index),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPublicDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: Column(
        children: [
          // Public header with real gym asset
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              image: DecorationImage(
                image: AssetImage('assets/public/img.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PULSE & POWER FITNESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Build Strength. Transform Life.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerTile(Icons.home_rounded, 'Home', 0),
                _drawerTile(Icons.info_rounded, 'About Us', 1),
                _drawerTile(
                  Icons.card_membership_rounded,
                  'Membership Plans',
                  2,
                ),
                _drawerTile(
                  Icons.local_offer_rounded,
                  'Promotions & Offers',
                  3,
                ),
                _drawerTile(Icons.photo_library_rounded, 'Gallery', 4),
                _drawerTile(Icons.sports_rounded, 'Trainers', 5),
                _drawerTile(Icons.contact_mail_rounded, 'Contact Us', 6),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.login_rounded,
                    color: AppColors.info,
                    size: 22,
                  ),
                  title: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Access Member, Trainer, or Admin portal',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_add_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                  title: const Text(
                    'Join Now',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Create a new member account',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.palette_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  title: const Text(
                    'Theme & Appearance',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ThemeSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : Colors.white70,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context);
        setState(() => _currentIndex = index);
      },
      dense: true,
    );
  }
}
