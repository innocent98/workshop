class SendOtpRequest {
  final String userId;

  SendOtpRequest({required this.userId});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
      };
}
