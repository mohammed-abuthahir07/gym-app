import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/exercise_model.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';

class MemberExercisesScreen extends StatefulWidget {
  const MemberExercisesScreen({super.key});

  @override
  State<MemberExercisesScreen> createState() => _MemberExercisesScreenState();
}

class _MemberExercisesScreenState extends State<MemberExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDifficulty = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = Provider.of<MemberProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final theme = Theme.of(context);

    final filteredExercises = member.exercises.where((ex) {
      if (_selectedDifficulty != 'ALL' &&
          ex.difficulty.toUpperCase() != _selectedDifficulty) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return ex.name.toLowerCase().contains(q) ||
          ex.muscleGroup.toLowerCase().contains(q) ||
          ex.equipment.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises, muscles, equipment...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Difficulties'),
                      const SizedBox(width: 8),
                      _buildFilterChip('BEGINNER', 'Beginner'),
                      const SizedBox(width: 8),
                      _buildFilterChip('INTERMEDIATE', 'Intermediate'),
                      const SizedBox(width: 8),
                      _buildFilterChip('DIFFICULT', 'Difficult'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main List with States
          Expanded(
            child: member.isLoading && member.exercises.isEmpty
                ? const LoadingView(message: 'Loading exercise library...')
                : RefreshIndicator(
                    onRefresh: () async {
                      if (user != null) {
                        await member.loadMemberData(user.id, user.trainerId);
                      }
                    },
                    child: member.exercises.isEmpty
                        ? const EmptyState(
                            title: 'No Exercises Available',
                            message: 'The gym exercise library is currently being updated. Check back shortly.',
                            icon: Icons.fitness_center_outlined,
                          )
                        : filteredExercises.isEmpty
                        ? EmptyState(
                            title: 'No Matching Exercises',
                            message:
                                'No exercises match your search query "$_searchQuery".',
                            icon: Icons.search_off_rounded,
                            action: ElevatedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedDifficulty = 'ALL';
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset Filters'),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: filteredExercises.length,
                            itemBuilder: (ctx, idx) {
                              final ex = filteredExercises[idx];
                              return _buildExerciseCard(ex, theme);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedDifficulty == value;
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.35),
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.dividerColor.withValues(alpha: 0.2),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? value : 'ALL';
        });
      },
    );
  }

  Widget _buildExerciseCard(ExerciseModel ex, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Image with fallback
          if (ex.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  ex.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surfaceCard,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, stack) => _buildImageFallback(ex),
                ),
              ),
            ),
          ] else ...[
            _buildHeaderThumbnail(ex, theme),
          ],

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ex.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ex.difficulty == 'BEGINNER'
                            ? AppColors.success.withValues(alpha: 0.15)
                            : ex.difficulty == 'INTERMEDIATE'
                            ? AppColors.info.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ex.difficulty,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ex.difficulty == 'BEGINNER'
                              ? AppColors.success
                              : ex.difficulty == 'INTERMEDIATE'
                              ? AppColors.info
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.accessibility_new_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            ex.muscleGroup,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ex.equipment.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            size: 15,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              ex.equipment,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (ex.instructions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    ex.instructions,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback(ExerciseModel ex) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
              size: 36,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                ex.name,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderThumbnail(ExerciseModel ex, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ex.muscleGroup.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
