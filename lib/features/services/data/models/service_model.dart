class ServiceModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'];
    final updatedAtRaw = json['updated_at'];

    return ServiceModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      categoryId: json['category_id']?.toString(),
      categoryName: (json['category'] is Map<String, dynamic>)
          ? (json['category']['name'] as String?)
          : null,
      createdAt: createdAtRaw is String
          ? DateTime.tryParse(createdAtRaw)
          : null,
      updatedAt: updatedAtRaw is String
          ? DateTime.tryParse(updatedAtRaw)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
