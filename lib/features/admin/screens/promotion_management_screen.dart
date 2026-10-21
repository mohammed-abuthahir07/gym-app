import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/promotion_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class PromotionManagementScreen extends StatefulWidget {
  const PromotionManagementScreen({super.key});

  @override
  State<PromotionManagementScreen> createState() =>
      _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  void _showAddPromotionDialog() {
    final titleCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final startCtrl = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
    final endCtrl = TextEditingController(
      text: DateTime.now()
          .add(const Duration(days: 30))
          .toString()
          .split(' ')[0],
    );
    String discountType = 'PERCENTAGE';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Promotion Offer'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleCtrl,
                    label: 'Promotion Title',
                    hint: 'e.g. New Year Offer',
                    validator: (v) => AppValidators.requiredField(v, 'Title'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: codeCtrl,
                    label: 'Coupon Code',
                    hint: 'e.g. NY2026',
                    validator: (v) => AppValidators.requiredField(v, 'Code'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description',
                    hint: 'e.g. 20 percent off all plans',
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: discountCtrl,
                          label: 'Discount Value',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, 'Discount'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: discountType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          items: ['PERCENTAGE', 'FIXED'].map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(
                                t,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => discountType = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: startCtrl,
                          label: 'Start Date',
                          hint: 'YYYY-MM-DD',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'Start date'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: endCtrl,
                          label: 'End Date',
                          hint: 'YYYY-MM-DD',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'End date'),
                        ),
                      ),
                    ],
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
              text: 'Create Promotion',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final promo = PromotionModel(
                    id: '',
                    title: titleCtrl.text.trim(),
                    code: codeCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    discount: double.parse(discountCtrl.text.trim()),
                    discountType: discountType,
                    startDate: startCtrl.text.trim(),
                    endDate: endCtrl.text.trim(),
                    status: 'ACTIVE',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).addPromotion(promo);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Promotion created successfully!'),
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
      appBar: AppBar(title: const Text('Promotions & Discounts')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddPromotionDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Promotion'),
      ),
      body: admin.promotions.isEmpty
          ? const EmptyState(
              title: 'No Promotions',
              message: 'Create discount codes and seasonal offers for gym subscriptions.',
              icon: Icons.local_offer,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.promotions.length,
              itemBuilder: (ctx, idx) {
                final promo = admin.promotions[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.percent, color: Colors.white),
                    ),
                    title: Text(
                      promo.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(promo.description),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${promo.code} • ${promo.startDate} to ${promo.endDate}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          promo.discountType == 'PERCENTAGE'
                              ? '${promo.discount.toStringAsFixed(0)}% OFF'
                              : '₹${promo.discount.toStringAsFixed(0)} OFF',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.error,
                          ),
                          onPressed: () => admin.deletePromotion(promo.id),
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
