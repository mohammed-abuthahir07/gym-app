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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _service = FirestoreService();
  bool _isSending = false;
  Future<String>? _conversationReady;
  Stream<List<MessageModel>>? _messageStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final trainer = auth.currentUser;
      if (trainer == null || widget.member.id.isEmpty) return;
      setState(() {
        _conversationReady = _service
            .ensureConversation(
              memberId: widget.member.id,
              trainerId: trainer.id,
              memberName: widget.member.name,
              trainerName: trainer.name,
              memberEmail: widget.member.email,
              trainerEmail: trainer.email,
            )
            .then((convId) {
              _messageStream = _service.getConversationStream(
                trainer.id,
                widget.member.id,
              );
              return convId;
            });
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String trainerId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentTrainer = auth.currentUser;

    setState(() => _isSending = true);

    final now = DateTime.now();
    final msg = MessageModel(
      id: '',
      senderId: trainerId,
      senderRole: 'TRAINER',
      receiverId: widget.member.id,
      receiverRole: 'MEMBER',
      message: text,
      isRead: false,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _service.sendMessage(
        msg,
        memberName: widget.member.name,
        trainerName: currentTrainer?.name,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().toLowerCase();
        String displayMsg = 'Failed to send message. Please retry.';
        if (errStr.contains('permission-denied')) {
          displayMsg = 'Permission error: You are not authorized to send messages to this member.';
        } else if (errStr.contains('network') ||
            errStr.contains('unavailable')) {
          displayMsg = 'Connection issue. Your message has been preserved, please retry.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(displayMsg), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Widget _conversationError(String error, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load conversation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              error.toLowerCase().contains('permission-denied')
                  ? 'Access restricted: Please check your trainer account permissions.'
                  : 'Please check your connection and retry.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
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
            Text(
              widget.member.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
            child: FutureBuilder<String>(
              future: _conversationReady,
              builder: (ctx, convSnapshot) {
                if (_conversationReady == null ||
                    convSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (convSnapshot.hasError) {
                  return _conversationError(
                    convSnapshot.error.toString(),
                    onRetry: () {
                      final trainer = auth.currentUser;
                      if (trainer == null) return;
                      setState(() {
                        _conversationReady = _service
                            .ensureConversation(
                              memberId: widget.member.id,
                              trainerId: trainer.id,
                              memberName: widget.member.name,
                              trainerName: trainer.name,
                              memberEmail: widget.member.email,
                              trainerEmail: trainer.email,
                            )
                            .then((convId) {
                              _messageStream = _service.getConversationStream(
                                trainer.id,
                                widget.member.id,
                              );
                              return convId;
                            });
                      });
                    },
                  );
                }

                return StreamBuilder<List<MessageModel>>(
                  stream:
                      _messageStream ??
                      _service.getConversationStream(
                        trainerId,
                        widget.member.id,
                      ),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _conversationError(
                        snapshot.error.toString(),
                        onRetry: () => setState(() {
                          _messageStream = _service.getConversationStream(
                            trainerId,
                            widget.member.id,
                          );
                        }),
                      );
                    }

                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 56,
                                color: AppColors.primary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Conversation with ${widget.member.name}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'No messages yet. Send a message to start conversation!',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    _scrollToBottom();

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (ctx, idx) {
                        final m = messages[idx];
                        final isMe = m.senderId == trainerId;

                        // Mark as read if not read and received by me
                        if (!isMe && !m.isRead) {
                          _service.markMessageRead(
                            m.id,
                            userA: trainerId,
                            userB: widget.member.id,
                          );
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
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
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
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.primary,
                          ),
                    onPressed: _isSending
                        ? null
                        : () => _sendMessage(trainerId),
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
