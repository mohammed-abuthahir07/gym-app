import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/public_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

/// Professional contact enquiry modal popup with smooth animation,
/// full validation, double-tap prevention, and dark/red styling.
class ContactEnquiryDialog extends StatefulWidget {
  const ContactEnquiryDialog({super.key});

  /// Displays the modal enquiry popup with a fade and scale animation.
  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close contact modal',
      barrierColor: Colors.black.withValues(alpha: 0.78),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const ContactEnquiryDialog(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  State<ContactEnquiryDialog> createState() => _ContactEnquiryDialogState();
}

class _ContactEnquiryDialogState extends State<ContactEnquiryDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return; // Prevent double taps
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = Provider.of<PublicProvider>(context, listen: false);
    final success = await provider.submitContactEnquiry(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enquiry received! Our Pulse & Power team will contact you shortly.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Unable to send enquiry. Please check your connection and try again.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22,
                  20,
                  22,
                  22 + mediaQuery.viewInsets.bottom * 0.4,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with Title & Close (✕) Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send Us a Message',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Pulse & Power Fitness',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context, false),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Have queries regarding memberships, coaching, or class schedules? Send us your message.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),

                      // Form Fields
                      CustomTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'e.g. John Doe',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) =>
                            AppValidators.requiredField(v, 'Name'),
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        hint: 'e.g. member@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _phoneCtrl,
                        label: 'Phone Number',
                        hint: 'e.g. +91 98765 43210',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: AppValidators.phone,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _messageCtrl,
                        label: 'Message / Inquiry',
                        hint: 'How can we help you?',
                        prefixIcon: Icons.chat_bubble_outline_rounded,
                        maxLines: 3,
                        validator: (v) =>
                            AppValidators.requiredField(v, 'Message'),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      CustomButton(
                        text: 'Send Enquiry',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
