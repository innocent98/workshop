class ForgotPasswordSendCodeRequest {
  final String email;

  ForgotPasswordSendCodeRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}
