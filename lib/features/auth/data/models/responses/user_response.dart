import '../../../../../core/models/user.dart';

class UserResponse {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String? profilePictureUrl;
  final String? bio;
  final List<String>? services;
  final DateTime? createdAt;

  UserResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.profilePictureUrl,
    this.bio,
    this.services,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      userType: json['user_type'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  User toUser() {
    return User(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: userType == 'artisan' ? UserRole.artisan : UserRole.client,
      userType: userType,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      services: services,
      createdAt: createdAt,
    );
  }
}
