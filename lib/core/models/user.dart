enum UserRole {
  client,
  artisan,
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;
  final UserRole role;
  final String userType;
  final String? bio;
  final List<String>? services;
  final String? location;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    required this.userType,
    this.bio,
    this.services,
    this.location,
    this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'role': role.name,
      'userType': userType,
      'bio': bio,
      'services': services,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    final userType = json['userType'] as String? ?? json['user_type'] as String? ?? 'client';
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      role: userType == 'artisan' ? UserRole.artisan : UserRole.client,
      userType: userType,
      bio: json['bio'] as String?,
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : null,
      location: json['location'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    UserRole? role,
    String? userType,
    String? bio,
    List<String>? services,
    String? location,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      services: services ?? this.services,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
