import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/trainer_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class TrainerCheatDaysScreen extends StatefulWidget {
  const TrainerCheatDaysScreen({super.key});

  @override
  State<TrainerCheatDaysScreen> createState() => _TrainerCheatDaysScreenState();
}

class _TrainerCheatDaysScreenState extends State<TrainerCheatDaysScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'CURRENT_MONTH', 'PREVIOUS_MONTH'
  String? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context);

    final now = DateTime.now();
    final currentYearMonth = DateFormat('yyyy-MM').format(now);
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final prevYearMonth = DateFormat('yyyy-MM').format(prevMonthDate);

    final filteredCheatDays = trainer.cheatDays.where((c) {
      if (_selectedFilter == 'CURRENT_MONTH' &&
          !c.cheatDate.startsWith(currentYearMonth)) {
        return false;
      }
      if (_selectedFilter == 'PREVIOUS_MONTH' &&
          !c.cheatDate.startsWith(prevYearMonth)) {
        return false;
      }
      if (_selectedMemberId != null && c.memberId != _selectedMemberId) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Member Cheat-Day Logs')),
      body: Column(
        children: [
          // Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Entries'),
                  selected: _selectedFilter == 'ALL',
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = 'ALL');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('This Month'),
                  selected: _selectedFilter == 'CURRENT_MONTH',
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = 'CURRENT_MONTH');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Last Month'),
                  selected: _selectedFilter == 'PREVIOUS_MONTH',
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilter = 'PREVIOUS_MONTH');
                  },
                ),
                if (trainer.assignedMembers.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: _selectedMemberId,
                    hint: const Text(
                      'Filter Member',
                      style: TextStyle(fontSize: 12),
                    ),
                    underline: const SizedBox.shrink(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All Members',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ...trainer.assignedMembers.map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(
                            m.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedMemberId = val),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Expanded(
            child: filteredCheatDays.isEmpty
                ? const EmptyState(
                    title: 'No Cheat Activities Found',
                    message: 'No cheat meals or treats match the selected month or member filter.',
                    icon: Icons.fastfood_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCheatDays.length,
                    itemBuilder: (ctx, idx) {
                      final c = filteredCheatDays[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.warning,
                            child: Icon(Icons.fastfood, color: Colors.white),
                          ),
                          title: Text(
                            '${c.foodName} (${c.quantity})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Member: ${c.memberName ?? 'Member'} • Date: ${c.cheatDate}',
                              ),
                              Text(
                                '${c.calories} calories',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              if (c.notes != null && c.notes!.isNotEmpty)
                                Text(
                                  'Note: ${c.notes}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
