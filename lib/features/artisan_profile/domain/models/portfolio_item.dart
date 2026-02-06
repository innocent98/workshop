class PortfolioItem {
  final String id;
  final String title;
  final String imageUrl;
  final String? description;
  final DateTime? projectDate;
  final int? displayOrder;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.description,
    this.projectDate,
    this.displayOrder,
  });
}
