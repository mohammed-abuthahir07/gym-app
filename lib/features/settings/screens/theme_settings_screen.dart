import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  void _showColorEditDialog(
    BuildContext context,
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    final hexController = TextEditingController(
      text:
          '#${currentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    );

    final palette = [
      const Color(0xFFE50914), // Gym Red
      const Color(0xFFD32F2F),
      const Color(0xFF0070F3), // Electric Blue
      const Color(0xFF2196F3),
      const Color(0xFF00C853), // Emerald Green
      const Color(0xFF4CAF50),
      const Color(0xFFFFB300), // Gold
      const Color(0xFFFF5722), // Orange Accent
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF121212), // Dark Background
      const Color(0xFF1E1E1E), // Card Surface
      const Color(0xFF252525),
      const Color(0xFF333333),
      const Color(0xFFF8F9FA), // Clean Light
      const Color(0xFFFFFFFF), // Pure White
      const Color(0xFFAAAAAA), // Muted Grey
      const Color(0xFF212121), // Charcoal Text
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose $title'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Palette:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: palette.map((color) {
                  return GestureDetector(
                    onTap: () {
                      onColorChanged(color);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color == currentColor
                              ? Colors.white
                              : Colors.grey,
                          width: color == currentColor ? 2.5 : 1.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Or Enter Hex Code (#RRGGBB):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hexController,
                decoration: const InputDecoration(
                  hintText: '#FF5722',
                  prefixIcon: Icon(Icons.colorize),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final hex = hexController.text.replaceAll('#', '').trim();
              if (hex.length == 6) {
                final intVal = int.tryParse('FF$hex', radix: 16);
                if (intVal != null) {
                  onColorChanged(Color(intVal));
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final custom = themeProvider.customTheme;

    final presets = [
      'Gym Red (Default)',
      'Electric Blue',
      'Emerald Power',
      'Gold Championship',
      'Clean Light',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Appearance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset to Default',
            onPressed: () async {
              await themeProvider.resetToDefault();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme reset to default settings.'),
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
            // Mode Selector
            const Text(
              'Theme Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Dark Mode')),
                    selected: themeProvider.isDarkMode,
                    onSelected: (val) {
                      if (val) themeProvider.toggleThemeMode(ThemeMode.dark);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Light Mode')),
                    selected: !themeProvider.isDarkMode,
                    onSelected: (val) {
                      if (val) themeProvider.toggleThemeMode(ThemeMode.light);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Presets
            const Text(
              'Design Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((p) {
                return ActionChip(
                  label: Text(p),
                  avatar: const Icon(Icons.palette_outlined, size: 16),
                  onPressed: () => themeProvider.applyPreset(p),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Customizable Color Roles
            const Text(
              'Customize Color Roles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap any color swatch to pick a color or enter a hex code. Updates apply instantly.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),

            Card(
              child: Column(
                children: [
                  _buildColorTile(
                    context: context,
                    title: 'Primary Color',
                    subtitle:
                        'Main branding, active indicators & primary highlights',
                    color: custom.primary,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Primary Color',
                      custom.primary,
                      (c) => themeProvider.updateColor(primary: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Accent Color',
                    subtitle: 'Secondary badges, tags, and callouts',
                    color: custom.accent,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Accent Color',
                      custom.accent,
                      (c) => themeProvider.updateColor(accent: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Main Background',
                    subtitle: 'Scaffold background and full-page canvas',
                    color: custom.background,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Background Color',
                      custom.background,
                      (c) => themeProvider.updateColor(background: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Surface / Card Color',
                    subtitle: 'Containers, cards, dialogs, and text fields',
                    color: custom.surface,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Surface Color',
                      custom.surface,
                      (c) => themeProvider.updateColor(surface: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Button Background',
                    subtitle: 'Elevated action buttons and primary controls',
                    color: custom.buttonColor,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Button Color',
                      custom.buttonColor,
                      (c) => themeProvider.updateColor(buttonColor: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Button Text Color',
                    subtitle: 'Text and icons inside buttons',
                    color: custom.buttonTextColor,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Button Text Color',
                      custom.buttonTextColor,
                      (c) => themeProvider.updateColor(buttonTextColor: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Primary Text Color',
                    subtitle: 'Headers, prominent labels, and title texts',
                    color: custom.textPrimary,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Primary Text Color',
                      custom.textPrimary,
                      (c) => themeProvider.updateColor(textPrimary: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Secondary Text Color',
                    subtitle: 'Descriptions, subtitles, and placeholder hints',
                    color: custom.textSecondary,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Secondary Text Color',
                      custom.textSecondary,
                      (c) => themeProvider.updateColor(textSecondary: c),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    context: context,
                    title: 'Border & Divider Color',
                    subtitle:
                        'Card outlines, table lines, and container borders',
                    color: custom.cardBorder,
                    onTap: () => _showColorEditDialog(
                      context,
                      'Border Color',
                      custom.cardBorder,
                      (c) => themeProvider.updateColor(cardBorder: c),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Preview Card
            const Text(
              'Live Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Heading Text',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: custom.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This is secondary body text showing contrast against surface.',
                      style: TextStyle(color: custom.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Sample Primary Button',
                      backgroundColor: custom.buttonColor,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final hexString =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hexString,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
