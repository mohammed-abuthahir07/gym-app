import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/user_model.dart';
import '../../../models/message_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';

class TrainerChatScreen extends StatefulWidget {
  final UserModel member;

  const TrainerChatScreen({super.key, required this.member});

  @override
  State<TrainerChatScreen> createState() => _TrainerChatScreenState();
}

class _TrainerChatScreenState extends State<TrainerChatScreen> {
  final _messageController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String trainerId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final msg = MessageModel(
      id: '',
      senderId: trainerId,
      senderRole: 'TRAINER',
      receiverId: widget.member.id,
      receiverRole: 'MEMBER',
      message: text,
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _service.sendMessage(msg);
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final trainerId = auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.member.name, style: const TextStyle(fontSize: 16)),
            Text(
              widget.member.email,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _service.getConversationStream(
                trainerId,
                widget.member.id,
              ),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Send a message to start conversation!',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (ctx, idx) {
                    final m = messages[idx];
                    final isMe = m.senderId == trainerId;

                    // Mark as read if not read and received by me
                    if (!isMe && !m.isRead) {
                      _service.markMessageRead(m.id);
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: isMe
                              ? null
                              : Border.all(color: AppColors.cardBorder),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppDateUtils.formatTime(m.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white70
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(trainerId),
                    ),
                  ),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () => _sendMessage(trainerId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
