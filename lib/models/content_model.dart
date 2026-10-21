import '../core/utils/date_utils.dart';

class ContentModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    this.image = '',
    this.createdAt,
    this.updatedAt,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContentModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      createdAt: AppDateUtils.parseDateTime(map['created_at']),
      updatedAt: AppDateUtils.parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
