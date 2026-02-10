class ArtisanSearchModel {
  final String id;
  final String? userId;
  final String? fullName;
  final String? bio;
  final double? experienceYears;
  final String? portfolioUrl;
  final String? certifications;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final List<ServiceInfo> services;
  final double? distanceKm;
  final double? averageRating;
  final int? ratingsCount;
  final int? totalJobsCompleted;

  const ArtisanSearchModel({
    required this.id,
    this.userId,
    this.fullName,
    this.bio,
    this.experienceYears,
    this.portfolioUrl,
    this.certifications,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.services = const [],
    this.distanceKm,
    this.averageRating,
    this.ratingsCount,
    this.totalJobsCompleted,
  });

  factory ArtisanSearchModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'] as List? ?? const [];
    final fullName = json['full_name'] as String?;

    return ArtisanSearchModel(
      id: (json['id'] ?? '').toString(),
      userId: json['user_id']?.toString(),
      fullName: fullName,
      bio: json['bio'] as String?,
      experienceYears: json['experience_years'] != null
          ? (json['experience_years'] as num).toDouble()
          : json['years_of_experience'] != null
          ? (json['years_of_experience'] as num).toDouble()
          : null,
      portfolioUrl:
          json['portfolio_url'] as String? ??
          json['portfolio_sample'] as String?,
      certifications: json['certifications'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      firstName: json['first_name'] as String? ?? _firstName(fullName),
      lastName: json['last_name'] as String? ?? _lastName(fullName),
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePictureUrl:
          json['profile_picture_url'] as String? ??
          json['profile_picture'] as String?,
      services: rawServices
          .whereType<Object>()
          .map(ServiceInfo.fromDynamic)
          .toList(),
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      ratingsCount:
          json['ratings_count'] as int? ?? json['total_ratings'] as int?,
      totalJobsCompleted: json['total_jobs_completed'] as int?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String? _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return null;
    }
    return fullName.trim().split(RegExp(r'\s+')).first;
  }

  static String? _lastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return null;
    }
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return null;
    }
    return parts.sublist(1).join(' ');
  }
}

class ServiceInfo {
  final String id;
  final String name;
  final String? imageUrl;

  const ServiceInfo({required this.id, required this.name, this.imageUrl});

  factory ServiceInfo.fromDynamic(Object value) {
    if (value is String) {
      return ServiceInfo(id: value, name: value);
    }
    if (value is Map<String, dynamic>) {
      return ServiceInfo.fromJson(value);
    }
    return ServiceInfo(id: value.toString(), name: value.toString());
  }

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: (json['id'] ?? json['name'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: json['image_url'] as String?,
    );
  }
}
