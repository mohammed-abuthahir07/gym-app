import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/class_schedule_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class TrainerSchedulesScreen extends StatefulWidget {
  const TrainerSchedulesScreen({super.key});

  @override
  State<TrainerSchedulesScreen> createState() => _TrainerSchedulesScreenState();
}

class _TrainerSchedulesScreenState extends State<TrainerSchedulesScreen> {
  void _showAddScheduleDialog() {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final titleCtrl = TextEditingController(text: 'Morning HIIT');
    final dateCtrl = TextEditingController(
      text: AppDateUtils.todayDateString(),
    );
    final startCtrl = TextEditingController(text: '07:00:00');
    final endCtrl = TextEditingController(text: '08:00:00');
    final capCtrl = TextEditingController(text: '20');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Schedule Group Class'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleCtrl,
                    label: 'Class Title',
                    hint: 'e.g. Morning HIIT / Evening Strength',
                    validator: (v) => AppValidators.requiredField(v, 'Title'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: dateCtrl,
                    label: 'Date (YYYY-MM-DD)',
                    validator: (v) => AppValidators.requiredField(v, 'Date'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: startCtrl,
                          label: 'Start (HH:mm:ss)',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'Start time'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: endCtrl,
                          label: 'End (HH:mm:ss)',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'End time'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: capCtrl,
                    label: 'Max Capacity',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.positiveNumber(v, 'Capacity'),
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
              text: 'Save Schedule',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final now = DateTime.now();
                  final schedule = ClassScheduleModel(
                    id: '',
                    trainerId: auth.currentUser!.id,
                    trainerName: auth.currentUser!.name,
                    trainerEmail: auth.currentUser!.email,
                    title: titleCtrl.text.trim(),
                    classDate: dateCtrl.text.trim(),
                    startTime: startCtrl.text.trim(),
                    endTime: endCtrl.text.trim(),
                    capacity: int.parse(capCtrl.text.trim()),
                    createdAt: now,
                    updatedAt: now,
                  );
                  await trainer.addSchedule(schedule);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Class scheduled successfully!'),
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

  void _showEditScheduleDialog(ClassScheduleModel schedule) {
    final trainer = Provider.of<TrainerProvider>(context, listen: false);

    final titleCtrl = TextEditingController(text: schedule.title);
    final dateCtrl = TextEditingController(text: schedule.classDate);
    final startCtrl = TextEditingController(text: schedule.startTime);
    final endCtrl = TextEditingController(text: schedule.endTime);
    final capCtrl = TextEditingController(text: schedule.capacity.toString());
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit ${schedule.title}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleCtrl,
                    label: 'Class Title',
                    validator: (v) => AppValidators.requiredField(v, 'Title'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: dateCtrl,
                    label: 'Date (YYYY-MM-DD)',
                    validator: (v) => AppValidators.requiredField(v, 'Date'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: startCtrl,
                          label: 'Start (HH:mm:ss)',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'Start time'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: endCtrl,
                          label: 'End (HH:mm:ss)',
                          validator: (v) =>
                              AppValidators.requiredField(v, 'End time'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: capCtrl,
                    label: 'Max Capacity',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        AppValidators.positiveNumber(v, 'Capacity'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Save',
              isLoading: isSaving,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => isSaving = true);
                try {
                  final updated = ClassScheduleModel(
                    id: schedule.id,
                    trainerId: schedule.trainerId,
                    trainerName: schedule.trainerName,
                    trainerEmail: schedule.trainerEmail,
                    title: titleCtrl.text.trim(),
                    classDate: dateCtrl.text.trim(),
                    startTime: startCtrl.text.trim(),
                    endTime: endCtrl.text.trim(),
                    capacity: int.parse(capCtrl.text.trim()),
                    createdAt: schedule.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await trainer.updateSchedule(updated);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Class schedule updated!'),
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
    final trainer = Provider.of<TrainerProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Class Schedules')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showAddScheduleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Schedule Class'),
      ),
      body: trainer.schedules.isEmpty
          ? const EmptyState(
              title: 'No Classes Scheduled',
              message:
                  'Schedule gym group classes, workouts, or cardio batches.',
              icon: Icons.calendar_today_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainer.schedules.length,
              itemBuilder: (ctx, idx) {
                final s = trainer.schedules[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.timer, color: Colors.white),
                    ),
                    title: Text(
                      s.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${s.classDate} • ${s.startTime} - ${s.endTime}\nCapacity: ${s.capacity} members',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          tooltip: 'Edit Class',
                          onPressed: () => _showEditScheduleDialog(s),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'Delete Class',
                          onPressed: () => trainer.deleteSchedule(
                            s.id,
                            auth.currentUser!.id,
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
