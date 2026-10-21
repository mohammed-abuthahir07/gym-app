import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../models/content_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  void _showAddContentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Fitness Article / Tip'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleCtrl,
                    label: 'Article Title',
                    hint: 'e.g. Summer Fitness Tips',
                    validator: (v) => AppValidators.requiredField(v, 'Title'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description / Content',
                    hint: 'e.g. Stay hydrated and train consistently...',
                    maxLines: 4,
                    validator: (v) =>
                        AppValidators.requiredField(v, 'Description'),
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
              text: 'Publish',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final content = ContentModel(
                    id: '',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).addContent(content);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Content published successfully!'),
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
      appBar: AppBar(title: const Text('Content Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddContentDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Article'),
      ),
      body: admin.contents.isEmpty
          ? const EmptyState(
              title: 'No Content Published',
              message:
                  'Publish workout tips, nutritional guidelines, and gym news.',
              icon: Icons.article_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.contents.length,
              itemBuilder: (ctx, idx) {
                final c = admin.contents[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => admin.deleteContent(c.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
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
