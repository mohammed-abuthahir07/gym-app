import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/public_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PublicProvider>(context, listen: false);
    final success = await provider.submitContactEnquiry(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      message: _messageController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enquiry sent successfully! Our team will contact you.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to send enquiry'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact & Enquiries')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Have a question about memberships, personal training, or programs? Send us an enquiry.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: 'Your Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => AppValidators.requiredField(v, 'Name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _messageController,
                  label: 'Your Message / Enquiry',
                  hint: 'Tell us what you would like to know...',
                  maxLines: 4,
                  validator: (v) => AppValidators.requiredField(v, 'Message'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Submit Enquiry',
                  isLoading: provider.isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
