class VerifyCodeResponse {
  final String resetToken;
  final String message;

  VerifyCodeResponse({
    required this.resetToken,
    required this.message,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      resetToken: json['reset_token'] as String,
      message: json['message'] as String? ?? 'Code verified successfully',
    );
  }
}
