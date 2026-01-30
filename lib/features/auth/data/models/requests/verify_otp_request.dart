class VerifyOtpRequest {
  final String userId;
  final String otp;

  VerifyOtpRequest({
    required this.userId,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'otp': otp,
      };
}
