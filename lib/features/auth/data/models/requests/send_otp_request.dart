class SendOtpRequest {
  final String userId;
  final String email;

  SendOtpRequest({required this.userId, required this.email});

  Map<String, dynamic> toJson() => {'user_id': userId, 'email': email};
}
