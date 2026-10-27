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

  void _showEditPlanDialog(PlanModel plan) {
    final nameCtrl = TextEditingController(text: plan.name);
    final descCtrl = TextEditingController(text: plan.description);
    final durValueCtrl = TextEditingController(
      text: plan.durationValue.toString(),
    );
    final priceCtrl = TextEditingController(
      text: plan.price.toStringAsFixed(0),
    );
    final featuresCtrl = TextEditingController(text: plan.extraFeatures);
    String durationUnit = plan.durationUnit;
    String status = plan.status;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit Plan: ${plan.name}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Plan Name',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Plan name'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description',
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
                    hint: 'e.g. Sauna, steam and locker included',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ACTIVE',
                        child: Text('Active (Visible to Members)'),
                      ),
                      DropdownMenuItem(
                        value: 'INACTIVE',
                        child: Text('Inactive (Archived)'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => status = v);
                      }
                    },
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
              text: 'Update Plan',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final updated = PlanModel(
                    id: plan.id,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    durationValue: int.parse(durValueCtrl.text.trim()),
                    durationUnit: durationUnit,
                    price: double.parse(priceCtrl.text.trim()),
                    extraFeatures: featuresCtrl.text.trim(),
                    status: status,
                    createdAt: plan.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).updatePlan(updated);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan updated successfully!'),
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

  void _showDeletePlanDialog(PlanModel plan) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              const Expanded(child: Text('Delete Membership Plan')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete the plan "${plan.name}"?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'If members or historical invoices are associated with this plan, it will be safely archived (marked Inactive) to preserve all historical financial and membership records.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      try {
                        await Provider.of<AdminProvider>(
                          context,
                          listen: false,
                        ).deletePlan(plan.id);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Plan "${plan.name}" removed/archived safely.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isDeleting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Delete Plan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final theme = Theme.of(context);

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
              message:
                  'Create subscription plans with prices, durations, and perks.',
              icon: Icons.card_membership,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.plans.length,
              itemBuilder: (ctx, idx) {
                final p = admin.plans[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!p.isActive) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ARCHIVED / INACTIVE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${p.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.description,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${p.durationValue} ${p.durationUnit.toLowerCase()}(s)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (p.extraFeatures.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.extraFeatures,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 6),
                        // Edit & Delete Action Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditPlanDialog(p),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                            ),
                            const SizedBox(width: 6),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              onPressed: () => _showDeletePlanDialog(p),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                              ),
                              label: const Text('Delete'),
                            ),
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
