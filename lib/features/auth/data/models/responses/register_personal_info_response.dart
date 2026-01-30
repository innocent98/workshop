class RegisterPersonalInfoResponse {
  final String userId;
  final String message;

  RegisterPersonalInfoResponse({
    required this.userId,
    required this.message,
  });

  factory RegisterPersonalInfoResponse.fromJson(Map<String, dynamic> json) {
    return RegisterPersonalInfoResponse(
      userId: json['user_id'] as String,
      message: json['message'] as String? ?? 'Personal information registered successfully',
    );
  }
}
