import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/plan_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class PlanManagementScreen extends StatefulWidget {
  const PlanManagementScreen({super.key});

  @override
  State<PlanManagementScreen> createState() => _PlanManagementScreenState();
}

class _PlanManagementScreenState extends State<PlanManagementScreen> {
  void _showAddPlanDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durValueCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    final featuresCtrl = TextEditingController();
    String durationUnit = 'MONTH';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Membership Plan'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Plan Name',
                    hint: 'e.g. Gold Plan',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Plan name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description',
                    hint: 'e.g. Full gym access with trainer support',
                    maxLines: 2,
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: durValueCtrl,
                          label: 'Duration',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Duration'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: durationUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          items: ['DAY', 'MONTH', 'YEAR'].map((u) {
                            return DropdownMenuItem(
                              value: u,
                              child: Text(
                                u,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => durationUnit = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: priceCtrl,
                    label: 'Price (₹)',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.nonNegativeNumber(v, 'Price'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: featuresCtrl,
                    label: 'Extra Features',
                    hint: 'e.g. Sauna and locker included',
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
              text: 'Save Plan',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final plan = PlanModel(
                    id: '',
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    durationValue: int.parse(durValueCtrl.text.trim()),
                    durationUnit: durationUnit,
                    price: double.parse(priceCtrl.text.trim()),
                    extraFeatures: featuresCtrl.text.trim(),
                    status: 'ACTIVE',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).addPlan(plan);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan created successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
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
      appBar: AppBar(title: const Text('Membership Plans')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddPlanDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
      body: admin.plans.isEmpty
          ? const EmptyState(
              title: 'No Plans Found',
              message: 'Create subscription plans with prices, durations, and perks.',
              icon: Icons.card_membership,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.plans.length,
              itemBuilder: (ctx, idx) {
                final p = admin.plans[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                '${p.durationValue} ${p.durationUnit.toLowerCase()}(s)',
                              ),
                              backgroundColor: AppColors.surface,
                            ),
                            if (p.extraFeatures.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.extraFeatures,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
