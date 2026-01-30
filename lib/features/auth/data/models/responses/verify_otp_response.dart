class VerifyOtpResponse {
  final String message;

  VerifyOtpResponse({required this.message});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] as String? ?? 'OTP verified successfully',
    );
  }
}
