class Service {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  const Service({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });
}
