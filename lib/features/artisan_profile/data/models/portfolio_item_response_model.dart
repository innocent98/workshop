import '../../domain/models/portfolio_item.dart';

/// Response model for portfolio item from API
class PortfolioItemResponseModel {
  final String id;
  final String imageUrl;
  final String title;
  final String? description;
  final String? projectDate;
  final int? displayOrder;

  const PortfolioItemResponseModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.description,
    this.projectDate,
    this.displayOrder,
  });

  factory PortfolioItemResponseModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemResponseModel(
      id: (json['id'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled project').toString(),
      description: json['description'] as String?,
      projectDate: json['project_date'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt(),
    );
  }

  PortfolioItem toDomain() {
    return PortfolioItem(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
      projectDate: projectDate != null ? DateTime.tryParse(projectDate!) : null,
      displayOrder: displayOrder,
    );
  }
}
