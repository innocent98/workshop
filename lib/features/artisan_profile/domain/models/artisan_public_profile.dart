import '../../../../core/utils/money_format.dart';

/// Domain model for public artisan profile data
class ArtisanPublicProfile {
  final String id;
  final String fullName;
  final String? bio;
  final String? locationAddress;
  final double? hourlyRateMin;
  final double? hourlyRateMax;
  final int? yearsOfExperience;
  final String? specialization;
  final double averageRating;
  final int totalRatings;
  final int totalJobsCompleted;

  const ArtisanPublicProfile({
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
  });

  String get hourlyRateRange {
    if (hourlyRateMin == null || hourlyRateMax == null) {
      return 'Not specified';
    }
    return '${formatNairaRange(hourlyRateMin!, hourlyRateMax!)}/hr';
  }
}
