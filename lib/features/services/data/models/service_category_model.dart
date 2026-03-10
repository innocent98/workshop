class ServiceCategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final int displayOrder;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    required this.displayOrder,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}
