class RegisterServicesRequest {
  final String userId;
  final String userType;
  final List<String> services;

  RegisterServicesRequest({
    required this.userId,
    required this.userType,
    required this.services,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_type': userType,
    'services': services,
  };
}
