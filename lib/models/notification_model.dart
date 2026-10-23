import '../core/utils/date_utils.dart';

class NotificationModel {
  final String id;
  final String? recipientId;
  final String recipientRole; // MEMBER, TRAINER, ALL_MEMBERS, ALL_TRAINERS
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    this.recipientId,
    required this.recipientRole,
    required this.title,
    required this.message,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawIsRead = map['is_read'];
    final readBool =
        rawIsRead == true ||
        rawIsRead == 1 ||
        rawIsRead == '1' ||
        rawIsRead == 'true';

    return NotificationModel(
      id: docId,
      recipientId: map['recipient_id']?.toString(),
      recipientRole: (map['recipient_role'] ?? 'MEMBER')
          .toString()
          .trim()
          .toUpperCase(),
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      isRead: readBool,
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipient_id': recipientId,
      'recipient_role': recipientRole,
      'title': title,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
