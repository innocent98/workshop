class ServiceCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final int displayOrder;

  const ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    required this.displayOrder,
  });
}
