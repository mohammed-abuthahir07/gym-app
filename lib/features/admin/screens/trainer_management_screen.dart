import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class TrainerManagementScreen extends StatefulWidget {
  const TrainerManagementScreen({super.key});

  @override
  State<TrainerManagementScreen> createState() =>
      _TrainerManagementScreenState();
}

class _TrainerManagementScreenState extends State<TrainerManagementScreen> {
  void _showAddTrainerDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'Trainer@123');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Trainer'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Trainer Name',
                    validator: (v) => AppValidators.requiredField(v, 'Name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: phoneCtrl,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: passwordCtrl,
                    label: 'Password',
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setDialogState(
                          () => obscurePassword = !obscurePassword,
                        );
                      },
                    ),
                    validator: AppValidators.password,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Create Trainer',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).createTrainer(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trainer created successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  String errorMsg = e.toString().replaceAll('Exception: ', '');
                  if (errorMsg.contains('permission-denied') ||
                      errorMsg.contains('PERMISSION_DENIED')) {
                    errorMsg = 'Firestore Permission Denied. Ensure your administrator account has the ADMIN role in Firestore users collection or updated security rules are deployed.';
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed: $errorMsg'),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddTrainerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Trainer'),
      ),
      body: admin.trainers.isEmpty
          ? const EmptyState(
              title: 'No Trainers Registered',
              message: 'Add trainers to assign members, schedules, and workout plans.',
              icon: Icons.sports,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.trainers.length,
              itemBuilder: (ctx, idx) {
                final t = admin.trainers[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.isActive
                          ? AppColors.accent
                          : AppColors.surface,
                      child: Text(
                        t.name.isNotEmpty ? t.name[0].toUpperCase() : 'T',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      t.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${t.email} • Phone: ${t.phone}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: t.isActive
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t.status,
                                style: TextStyle(
                                  color: t.isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: t.isActive
                        ? IconButton(
                            icon: const Icon(
                              Icons.block,
                              color: AppColors.error,
                            ),
                            tooltip: 'Deactivate Trainer',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Deactivate Trainer?'),
                                  content: Text(
                                    'Are you sure you want to deactivate ${t.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Deactivate',
                                        style: TextStyle(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await admin.deactivateTrainer(t.id);
                              }
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
