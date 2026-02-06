class ResetPasswordRequest {
  final String email;
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
}
