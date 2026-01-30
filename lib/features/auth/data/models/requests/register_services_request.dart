class RegisterServicesRequest {
  final String userId;
  final List<String> services;

  RegisterServicesRequest({
    required this.userId,
    required this.services,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'services': services,
      };
}
