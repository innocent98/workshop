import '../../../verification/domain/models/verification_status.dart';

enum AvailabilityStatus {
  available,
  busy,
  offline;

  String toApiString() => name;

  static AvailabilityStatus fromApiString(String value) {
    return AvailabilityStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AvailabilityStatus.offline,
    );
  }
}

class ArtisanProfile {
  final String id;
  final String fullName;
  final String? profilePictureUrl;
  final AvailabilityStatus availabilityStatus;
  final int totalJobsCompleted;
  final double averageRating;
  final String? bio;
  final double? hourlyRateMin;
  final double? hourlyRateMax;
  final int? yearsOfExperience;
  final String? specialization;
  final double? serviceRadiusKm;
  final List<String>? skills;
  final String? location;

  /// Additive backend field; [VerificationStatus.unknown] when absent.
  final VerificationStatus verificationStatus;
  final bool isVerified;

  const ArtisanProfile({
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
    this.specialization,
    this.serviceRadiusKm,
    this.skills,
    this.location,
    this.verificationStatus = VerificationStatus.unknown,
    this.isVerified = false,
  });

  /// `is_verified` is the source of truth for the badge, so a verified
  /// artisan always reads as verified even if the status field is missing.
  VerificationStatus get effectiveVerificationStatus =>
      isVerified ? VerificationStatus.verified : verificationStatus;

  ArtisanProfile copyWith({
    String? id,
    String? fullName,
    String? profilePictureUrl,
    AvailabilityStatus? availabilityStatus,
    int? totalJobsCompleted,
    double? averageRating,
    String? bio,
    double? hourlyRateMin,
    double? hourlyRateMax,
    int? yearsOfExperience,
    String? specialization,
    double? serviceRadiusKm,
    List<String>? skills,
    String? location,
    VerificationStatus? verificationStatus,
    bool? isVerified,
  }) {
    return ArtisanProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
      averageRating: averageRating ?? this.averageRating,
      bio: bio ?? this.bio,
      hourlyRateMin: hourlyRateMin ?? this.hourlyRateMin,
      hourlyRateMax: hourlyRateMax ?? this.hourlyRateMax,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specialization: specialization ?? this.specialization,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
