class RegistrationData {
  final String? userId;
  final String? userType;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final List<String>? selectedServices;
  final String? profilePictureUrl;
  final bool isOtpVerified;

  RegistrationData({
    this.userId,
    this.userType,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
    this.selectedServices,
    this.profilePictureUrl,
    this.isOtpVerified = false,
  });

  RegistrationData copyWith({
    String? userId,
    String? userType,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    List<String>? selectedServices,
    String? profilePictureUrl,
    bool? isOtpVerified,
  }) {
    return RegistrationData(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      selectedServices: selectedServices ?? this.selectedServices,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'selectedServices': selectedServices,
      'profilePictureUrl': profilePictureUrl,
      'isOtpVerified': isOtpVerified,
    };
  }

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      userId: json['userId'] as String?,
      userType: json['userType'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      password: json['password'] as String?,
      selectedServices: json['selectedServices'] != null
          ? List<String>.from(json['selectedServices'] as List)
          : null,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isOtpVerified: json['isOtpVerified'] as bool? ?? false,
    );
  }
}
