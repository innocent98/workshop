class RegisterPasswordRequest {
  final String userId;
  final String password;
  final String confirmPassword;

  RegisterPasswordRequest({
    required this.userId,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'password': password,
    'confirm_password': confirmPassword,
  };
}
