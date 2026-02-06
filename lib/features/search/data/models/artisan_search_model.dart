class ArtisanSearchModel {
  final String id;
  final String userId;
  final String? bio;
  final double? experienceYears;
  final String? portfolioUrl;
  final String? certifications;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final List<ServiceInfo>? services;
  final double? distanceKm;
  final double? averageRating;
  final int? ratingsCount;

  const ArtisanSearchModel({
    required this.id,
    required this.userId,
    this.bio,
    this.experienceYears,
    this.portfolioUrl,
    this.certifications,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.services,
    this.distanceKm,
    this.averageRating,
    this.ratingsCount,
  });

  factory ArtisanSearchModel.fromJson(Map<String, dynamic> json) {
    return ArtisanSearchModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bio: json['bio'] as String?,
      experienceYears: json['experience_years'] != null
          ? (json['experience_years'] as num).toDouble()
          : null,
      portfolioUrl: json['portfolio_url'] as String?,
      certifications: json['certifications'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      services: json['services'] != null
          ? (json['services'] as List)
              .map((s) => ServiceInfo.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      ratingsCount: json['ratings_count'] as int?,
    );
  }
}

class ServiceInfo {
  final String id;
  final String name;
  final String? imageUrl;

  const ServiceInfo({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}
