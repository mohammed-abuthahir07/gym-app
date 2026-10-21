import 'package:flutter/material.dart';

import 'public_website_shell.dart';

/// Entry point for signed-out public visitors.
/// Displays the full multi-page Gym Pro public website shell.
class PublicLandingPage extends StatelessWidget {
  const PublicLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicWebsiteShell();
  }
}
