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
}
