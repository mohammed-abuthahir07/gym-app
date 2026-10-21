import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../settings/screens/theme_settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _currentRole {
    switch (_tabController.index) {
      case 0:
        return 'MEMBER';
      case 1:
        return 'TRAINER';
      case 2:
        return 'ADMIN';
      default:
        return 'MEMBER';
    }
  }

  String get _roleDisplayName {
    switch (_tabController.index) {
      case 0:
        return 'Member';
      case 1:
        return 'Trainer';
      case 2:
        return 'Admin';
      default:
        return 'Member';
    }
  }

  Color get _roleColor {
    switch (_tabController.index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData get _roleIcon {
    switch (_tabController.index) {
      case 0:
        return Icons.person_rounded;
      case 1:
        return Icons.sports_rounded;
      case 2:
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
      expectedRole: _currentRole,
    );

    if (success && mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, st) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.background,
                      AppColors.primary.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top actions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white70,
                              ),
                              onPressed: () => Navigator.pop(context),
                            )
                          else
                            const SizedBox(width: 48),
                          IconButton(
                            icon: const Icon(
                              Icons.palette_outlined,
                              color: Colors.white70,
                            ),
                            tooltip: 'Theme & Appearance',
                            onPressed: () {
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

                    // Logo & branding
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _roleColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _roleColor.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _roleIcon,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PULSE & POWER',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sign in to your portal',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Login card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Role selector tabs
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: _roleColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.grey,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  onTap: (index) => setState(() {}),
                                  tabs: const [
                                    Tab(text: 'Member'),
                                    Tab(text: 'Trainer'),
                                    Tab(text: 'Admin'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _emailController,
                                      label: 'Email Address',
                                      hint: 'e.g. member@gmail.com',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: AppValidators.email,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      validator: AppValidators.password,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text('Forgot Password?'),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomButton(
                                      text: 'Sign In as $_roleDisplayName',
                                      backgroundColor: _roleColor,
                                      isLoading: authProvider.isLoading,
                                      onPressed: _handleLogin,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: _roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
