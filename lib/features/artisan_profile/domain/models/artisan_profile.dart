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
  final List<String>? skills;
  final String? location;

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
    this.skills,
    this.location,
  });

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
    List<String>? skills,
    String? location,
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
      skills: skills ?? this.skills,
      location: location ?? this.location,
    );
  }
}
