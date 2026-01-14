enum UserRole {
  client,
  artisan,
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final String? location;
  final String? service; // For artisans

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.location,
    this.service,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'location': location,
      'service': service,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.client,
      ),
      location: json['location'] as String?,
      service: json['service'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? location,
    String? service,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      location: location ?? this.location,
      service: service ?? this.service,
    );
  }
}
