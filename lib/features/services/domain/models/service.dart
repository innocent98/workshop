class Service {
  final String id;
  final String name;
  final String description;
  final String? image;
  final String? categoryId;

  Service({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.categoryId,
  });
}
