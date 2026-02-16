class VerifyOtpRequest {
  final String userId;
  final String otpCode;

  VerifyOtpRequest({required this.userId, required this.otpCode});

  Map<String, dynamic> toJson() => {'user_id': userId, 'otp_code': otpCode};
}
