class RegisterServicesResponse {
  final String message;

  RegisterServicesResponse({required this.message});

  factory RegisterServicesResponse.fromJson(Map<String, dynamic> json) {
    return RegisterServicesResponse(
      message: json['message'] as String? ?? 'Services registered successfully',
    );
  }
}
