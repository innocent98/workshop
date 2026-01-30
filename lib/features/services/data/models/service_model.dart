import '../../domain/models/service.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String? image;
  final String? categoryId;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.categoryId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      categoryId: json['category_id'] as String?,
    );
  }

  Service toEntity() {
    return Service(
      id: id,
      name: name,
      description: description,
      image: image,
      categoryId: categoryId,
    );
  }
}
