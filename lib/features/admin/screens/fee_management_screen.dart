import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/fee_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  void _showAddFeeDialog() {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    if (admin.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No members found to record fees for.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    UserModel selectedMember = admin.members.first;
    final amountCtrl = TextEditingController(text: '1500');
    final dateCtrl = TextEditingController(
      text: AppDateUtils.todayDateString(),
    );
    String feeMonth = AppDateUtils.currentMonthName();
    int feeYear = AppDateUtils.currentYear();
    String paymentStatus = 'PAID';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Record Member Fee'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UserModel>(
                    value: selectedMember,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Member',
                    ),
                    items: admin.members.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          '${m.name} (${m.email})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedMember = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: amountCtrl,
                    label: 'Fee Amount (₹)',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.positiveNumber(v, 'Fee amount'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: dateCtrl,
                    label: 'Payment Date (YYYY-MM-DD)',
                    validator: (v) => AppValidators.requiredField(v, 'Date'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: feeMonth,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          items: months
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => feeMonth = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: feeYear,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          items: [2025, 2026, 2027, 2028].map((y) {
                            return DropdownMenuItem(
                              value: y,
                              child: Text(
                                '$y',
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => feeYear = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: paymentStatus,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Payment Status',
                    ),
                    items: ['PAID', 'UNPAID', 'PENDING'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => paymentStatus = v);
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
              text: 'Save Fee Record',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final fee = FeeModel(
                    id: '',
                    memberId: selectedMember.id,
                    memberName: selectedMember.name,
                    memberEmail: selectedMember.email,
                    fitnessGoal: selectedMember.fitnessGoal ?? '',
                    feeAmount: double.parse(amountCtrl.text.trim()),
                    feeDate: dateCtrl.text.trim(),
                    feeMonth: feeMonth,
                    feeYear: feeYear,
                    paymentStatus: paymentStatus,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await admin.addFee(fee);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fee record created successfully!'),
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
      appBar: AppBar(title: const Text('Fee Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddFeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Record Fee'),
      ),
      body: admin.fees.isEmpty
          ? const EmptyState(
              title: 'No Fee Records',
              message: 'Record member fees, track monthly dues and revenue.',
              icon: Icons.payments_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.fees.length,
              itemBuilder: (ctx, idx) {
                final f = admin.fees[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: f.isPaid
                          ? AppColors.success
                          : AppColors.warning,
                      child: Icon(
                        f.isPaid ? Icons.check : Icons.access_time,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '${f.memberName} - ₹${f.feeAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Period: ${f.feeMonth} ${f.feeYear} • Date: ${f.feeDate}',
                        ),
                        Text(
                          'Status: ${f.paymentStatus}',
                          style: TextStyle(
                            color: f.isPaid
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => admin.deleteFee(f.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
