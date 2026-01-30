class RegisterPasswordResponse {
  final String message;

  RegisterPasswordResponse({required this.message});

  factory RegisterPasswordResponse.fromJson(Map<String, dynamic> json) {
    return RegisterPasswordResponse(
      message: json['message'] as String? ?? 'Password registered successfully',
    );
  }
}
