import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    final presets = [
      {
        'name': 'Gym Red (Default)',
        'primary': const Color(0xFFE50914),
        'accent': const Color(0xFFFF5722),
        'desc': 'High-energy signature gym red theme',
      },
      {
        'name': 'Electric Blue',
        'primary': const Color(0xFF0070F3),
        'accent': const Color(0xFF00DFD8),
        'desc': 'Modern electric blue athletic aesthetic',
      },
      {
        'name': 'Emerald Power',
        'primary': const Color(0xFF00C853),
        'accent': const Color(0xFF69F0AE),
        'desc': 'Vibrant health and endurance green',
      },
      {
        'name': 'Gold Championship',
        'primary': const Color(0xFFFFB300),
        'accent': const Color(0xFFFFD54F),
        'desc': 'Elite championship gold & amber accent',
      },
      {
        'name': 'Clean Light',
        'primary': const Color(0xFF1E88E5),
        'accent': const Color(0xFF0288D1),
        'desc': 'Crisp, high-contrast daytime interface',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Appearance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to Default',
            onPressed: () async {
              await themeProvider.resetToDefault();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme reset to default Gym Red settings.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // SECTION 1: THEME MODE
            // ==========================================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Theme Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Switch between dark and light appearance for all screens and dialogs.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildThemeModeCard(
                    context: context,
                    title: 'Dark Mode',
                    subtitle: 'Deep charcoal & gym ambiance',
                    icon: Icons.nightlight_round,
                    isSelected: themeProvider.isDarkMode,
                    onTap: () => themeProvider.toggleThemeMode(ThemeMode.dark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeModeCard(
                    context: context,
                    title: 'Light Mode',
                    subtitle: 'Clean white & daytime clarity',
                    icon: Icons.wb_sunny_rounded,
                    isSelected: !themeProvider.isDarkMode,
                    onTap: () => themeProvider.toggleThemeMode(ThemeMode.light),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ==========================================
            // SECTION 2: DESIGN PRESETS
            // ==========================================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Design Presets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a curated gym color scheme. Presets automatically adapt to both Dark and Light modes.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 14),

            ...presets.map((preset) {
              final name = preset['name'] as String;
              final primaryColor = preset['primary'] as Color;
              final accentColor = preset['accent'] as Color;
              final desc = preset['desc'] as String;
              final isSelected = themeProvider.activePreset == name;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => themeProvider.applyPreset(name),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Swatch indicators
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                desc,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _buildThemeModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 24,
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
