class Service {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;

  const Service({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
  });
}
