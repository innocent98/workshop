class Store {
  final String id;
  final String name;
  final String ownerName;
  final String description;
  final String imageUrl;
  final String avatarUrl;
  final double rating;
  final int salesCount;
  final String distance;

  const Store({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.description,
    required this.imageUrl,
    required this.avatarUrl,
    this.rating = 0.0,
    this.salesCount = 0,
    required this.distance,
  });
}
