import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/trainer_provider.dart';
import 'providers/member_provider.dart';
import 'providers/public_provider.dart';
import 'features/public/screens/public_landing_page.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/trainer/screens/trainer_dashboard_screen.dart';
import 'features/member/screens/member_dashboard_screen.dart';
import 'shared/widgets/loading_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => PublicProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProvider, child) {
          return MaterialApp(
            title: 'Pulse & Power',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Initializing Pulse & Power...'),
      );
    }

    final user = authProvider.currentUser;

    if (user == null) {
      // First-open and signed-out experience: Real Public Landing Page
      return const PublicLandingPage();
    }

    if (user.isAdmin) {
      return const AdminDashboardScreen();
    } else if (user.isTrainer) {
      return const TrainerDashboardScreen();
    } else {
      return const MemberDashboardScreen();
    }
  }
}
