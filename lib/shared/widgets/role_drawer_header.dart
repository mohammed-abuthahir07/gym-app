import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Premium drawer header designed for role portals.
/// Handles status bar insets safely and provides a rich background
/// with dark gradient overlay, avatar, role pill, name, and subtitle.
class RoleDrawerHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final String imagePath;
  final String? avatarText;
  final String? email;
  final VoidCallback? onProfileTap;

  const RoleDrawerHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.badgeText,
    this.badgeColor,
    this.avatarText,
    this.email,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = badgeColor ?? theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        image: DecorationImage(
          image: AssetImage(imagePath),
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
              Colors.black.withValues(alpha: 0.45),
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
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: accent,
                        child: Text(
                          avatarText?.isNotEmpty == true
                              ? avatarText![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (email != null && email!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onProfileTap != null)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        onPressed: onProfileTap,
                        tooltip: 'View Profile',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
