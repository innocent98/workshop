class RegisterPersonalInfoRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userType;

  RegisterPersonalInfoRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'user_type': userType,
      };
}
