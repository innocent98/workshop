class RegisterPasswordRequest {
  final String userId;
  final String password;

  RegisterPasswordRequest({
    required this.userId,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'password': password,
      };
}
