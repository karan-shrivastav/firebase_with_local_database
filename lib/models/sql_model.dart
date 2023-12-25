class SQLModel {
  final int id;
  final String title;
  final String description;
  final String createdAt;
  final String? updatedAt;

  SQLModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory SQLModel.fromSqfliteDatabase(Map<String, dynamic> map) => SQLModel(
    id: map['id']?.toInt() ?? 0,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'])
        .toIso8601String(),
    updatedAt: map['updated_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
        .toIso8601String(),
  );
}
