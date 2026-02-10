class ClientProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String? bio;
  final String? locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime createdAt;

  const ClientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.bio,
    this.locationAddress,
    this.locationLatitude,
    this.locationLongitude,
    required this.isEmailVerified,
    required this.isActive,
    required this.createdAt,
  });

  ClientProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    String? bio,
    String? locationAddress,
    double? locationLatitude,
    double? locationLongitude,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ClientProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      locationAddress: locationAddress ?? this.locationAddress,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
