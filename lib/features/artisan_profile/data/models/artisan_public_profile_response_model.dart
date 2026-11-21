import '../../domain/models/artisan_public_profile.dart';

/// Response model for public artisan profile from API
class ArtisanPublicProfileResponseModel {
  final String id;
  final String fullName;
  final String? bio;
  final String? locationAddress;
  final String? hourlyRateMin;
  final String? hourlyRateMax;
  final int? yearsOfExperience;
  final String? specialization;
  final double averageRating;
  final int totalRatings;
  final int totalJobsCompleted;
  final int? responseTimeAvgMinutes;

  const ArtisanPublicProfileResponseModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.locationAddress,
    this.hourlyRateMin,
    this.hourlyRateMax,
    this.yearsOfExperience,
    this.specialization,
    required this.averageRating,
    required this.totalRatings,
    required this.totalJobsCompleted,
    this.responseTimeAvgMinutes,
  });

  factory ArtisanPublicProfileResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ArtisanPublicProfileResponseModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      locationAddress: json['location_address'] as String?,
      hourlyRateMin: json['hourly_rate_min'] as String?,
      hourlyRateMax: json['hourly_rate_max'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      specialization: json['specialization'] as String?,
      averageRating: (json['average_rating'] as num).toDouble(),
      totalRatings: json['total_ratings'] as int,
      totalJobsCompleted: json['total_jobs_completed'] as int,
      // null and absent both mean "no data yet".
      responseTimeAvgMinutes: (json['response_time_avg_minutes'] as num?)
          ?.toInt(),
    );
  }

  ArtisanPublicProfile toDomain() {
    return ArtisanPublicProfile(
      id: id,
      fullName: fullName,
      bio: bio,
      locationAddress: locationAddress,
      hourlyRateMin: hourlyRateMin != null
          ? double.tryParse(hourlyRateMin!)
          : null,
      hourlyRateMax: hourlyRateMax != null
          ? double.tryParse(hourlyRateMax!)
          : null,
      yearsOfExperience: yearsOfExperience,
      specialization: specialization,
      averageRating: averageRating,
      totalRatings: totalRatings,
      totalJobsCompleted: totalJobsCompleted,
      responseTimeAvgMinutes: responseTimeAvgMinutes,
    );
  }
}
