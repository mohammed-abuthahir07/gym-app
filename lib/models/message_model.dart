import '../core/utils/date_utils.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderRole; // MEMBER, TRAINER, ADMIN
  final String receiverId;
  final String receiverRole;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.receiverId,
    required this.receiverRole,
    required this.message,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawIsRead = map['is_read'];
    final readBool = rawIsRead == true || rawIsRead == 1;

    return MessageModel(
      id: docId,
      senderId: map['sender_id'] ?? '',
      senderRole: (map['sender_role'] ?? 'MEMBER').toString().toUpperCase(),
      receiverId: map['receiver_id'] ?? '',
      receiverRole: (map['receiver_role'] ?? 'TRAINER')
          .toString()
          .toUpperCase(),
      message: map['message'] ?? '',
      isRead: readBool,
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'sender_role': senderRole,
      'receiver_id': receiverId,
      'receiver_role': receiverRole,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
