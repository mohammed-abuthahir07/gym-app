import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/user_model.dart';
import '../../../providers/trainer_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import 'trainer_chat_screen.dart';

class TrainerMembersChatScreen extends StatefulWidget {
  const TrainerMembersChatScreen({super.key});

  @override
  State<TrainerMembersChatScreen> createState() =>
      _TrainerMembersChatScreenState();
}

class _TrainerMembersChatScreenState extends State<TrainerMembersChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final trainerId = auth.currentUser?.id ?? '';

    final filteredMembers = trainer.assignedMembers.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.phone.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat with Members',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members by name or email...',
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
                fillColor: AppColors.surfaceCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),

          // Main body with live conversations stream
          Expanded(
            child: trainer.isLoading
                ? const LoadingView(message: 'Loading assigned members...')
                : trainer.errorMessage != null &&
                      trainer.assignedMembers.isEmpty
                ? EmptyState(
                    title: 'Unable to Load Members',
                    message: trainer.errorMessage!,
                    icon: Icons.wifi_off_rounded,
                    action: ElevatedButton.icon(
                      onPressed: () {
                        if (auth.currentUser != null) {
                          trainer.loadTrainerData(auth.currentUser!.id);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  )
                : trainer.assignedMembers.isEmpty
                ? const EmptyState(
                    title: 'No Assigned Members',
                    message: 'Members assigned to you by the administrator will appear here for messaging.',
                    icon: Icons.people_outline,
                  )
                : filteredMembers.isEmpty
                ? const EmptyState(
                    title: 'No Members Found',
                    message: 'No assigned members match your search criteria.',
                    icon: Icons.search_off_rounded,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      if (auth.currentUser != null) {
                        await trainer.loadTrainerData(auth.currentUser!.id);
                      }
                    },
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _service.getTrainerConversationsStream(trainerId),
                      builder: (ctx, snapshot) {
                        final conversations = snapshot.data ?? [];
                        final convMap = <String, Map<String, dynamic>>{};
                        for (final c in conversations) {
                          final memberId = c['member_id'];
                          if (memberId != null) {
                            convMap[memberId] = c;
                          }
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filteredMembers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, idx) {
                            final member = filteredMembers[idx];
                            final conv = convMap[member.id];
                            final lastMsg = conv?['last_message'] as String?;
                            final lastTimeStr =
                                conv?['last_message_time'] as String?;
                            final lastTime = AppDateUtils.parseDateTime(
                              lastTimeStr,
                            );

                            return _buildMemberCard(
                              context: context,
                              member: member,
                              lastMessage: lastMsg,
                              lastTime: lastTime,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard({
    required BuildContext context,
    required UserModel member,
    required String? lastMessage,
    required DateTime? lastTime,
  }) {
    final initials = member.name.isNotEmpty
        ? member.name.trim()[0].toUpperCase()
        : 'M';

    return Card(
      elevation: 0,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrainerChatScreen(member: member),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Member details & preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastTime != null)
                          Text(
                            AppDateUtils.formatTime(lastTime),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage != null && lastMessage.isNotEmpty
                          ? lastMessage
                          : member.fitnessGoal != null &&
                                member.fitnessGoal!.isNotEmpty
                          ? 'Goal: ${member.fitnessGoal}'
                          : 'Tap to start conversation',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: lastMessage != null && lastMessage.isNotEmpty
                            ? Colors.white70
                            : AppColors.textMuted,
                        fontStyle: lastMessage != null && lastMessage.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Trailing chevron icon
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
