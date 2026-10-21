import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/public_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class PublicContactScreen extends StatefulWidget {
  final bool isStandalone;
  const PublicContactScreen({super.key, this.isStandalone = false});

  @override
  State<PublicContactScreen> createState() => _PublicContactScreenState();
}

class _PublicContactScreenState extends State<PublicContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PublicProvider>(context, listen: false);
    final success = await provider.submitContactEnquiry(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );

    if (success && mounted) {
      _nameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enquiry received! Our Pulse & Power team will contact you shortly.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to submit enquiry'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicProvider = Provider.of<PublicProvider>(context);

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Info Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gym Information & Hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  title: 'Location & Address',
                  desc: 'Pulse & Power Fitness Complex, 4th Floor, Sports Hub, Main Avenue',
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  title: 'Operating Hours',
                  desc: 'Monday – Saturday: 06:00 AM – 10:00 PM\nSunday: 07:00 AM – 01:00 PM',
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.phone_rounded,
                  title: 'Phone & WhatsApp',
                  desc: '+91 98765 43210 / +91 87654 32109',
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.email_rounded,
                  title: 'Email Support',
                  desc: 'contact@pulseandpower.com / info@pulseandpower.com',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Enquiry Form
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Send Us a Message',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Have queries regarding memberships, coaching, or class schedules? Send us your message.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => AppValidators.requiredField(v, 'Name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _messageCtrl,
                    label: 'Message / Inquiry',
                    hint: 'How can we help you?',
                    maxLines: 4,
                    validator: (v) => AppValidators.requiredField(v, 'Message'),
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Send Enquiry',
                    isLoading: publicProvider.isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contact Pulse & Power')),
        body: content,
      );
    }

    return content;
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
