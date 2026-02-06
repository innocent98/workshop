import '../../domain/models/artisan_profile.dart';

class ArtisanProfileResponseModel {
  final String id;
  final String fullName;
  final String? profilePictureUrl;
  final String availabilityStatus;
  final int totalJobsCompleted;
  final double averageRating;
  final String? bio;
  final String? hourlyRateMin;
  final String? hourlyRateMax;
  final int? yearsOfExperience;
  final List<String>? skills;
  final String? location;

  const ArtisanProfileResponseModel({
    required this.id,
    required this.fullName,
    this.profilePictureUrl,
    required this.availabilityStatus,
    required this.totalJobsCompleted,
    required this.averageRating,
    this.bio,
    this.hourlyRateMin,
    this.hourlyRateMax,
    this.yearsOfExperience,
    this.skills,
    this.location,
  });

  factory ArtisanProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ArtisanProfileResponseModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      availabilityStatus: json['availability_status'] as String,
      totalJobsCompleted: (json['total_jobs_completed'] as num? ?? 0).toInt(),
      averageRating: (json['average_rating'] as num? ?? 0.0).toDouble(),
      bio: json['bio'] as String?,
      hourlyRateMin: json['hourly_rate_min'] as String?,
      hourlyRateMax: json['hourly_rate_max'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'] as List)
          : null,
      location: json['location'] as String?,
    );
  }

  ArtisanProfile toDomain() {
    return ArtisanProfile(
      id: id,
      fullName: fullName,
      profilePictureUrl: profilePictureUrl,
      availabilityStatus: AvailabilityStatus.fromApiString(availabilityStatus),
      totalJobsCompleted: totalJobsCompleted,
      averageRating: averageRating,
      bio: bio,
      hourlyRateMin: hourlyRateMin != null
          ? double.tryParse(hourlyRateMin!)
          : null,
      hourlyRateMax: hourlyRateMax != null
          ? double.tryParse(hourlyRateMax!)
          : null,
      yearsOfExperience: yearsOfExperience,
      skills: skills,
      location: location,
    );
  }
}
