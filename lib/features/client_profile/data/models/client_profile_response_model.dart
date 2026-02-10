import '../../domain/models/client_profile.dart';

class ClientProfileResponseModel {
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
  final String createdAt;

  const ClientProfileResponseModel({
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

  factory ClientProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileResponseModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      locationAddress: json['location_address'] as String?,
      locationLatitude: (json['location_latitude'] as num?)?.toDouble(),
      locationLongitude: (json['location_longitude'] as num?)?.toDouble(),
      isEmailVerified: json['is_email_verified'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  ClientProfile toDomain() {
    return ClientProfile(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      locationAddress: locationAddress,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
