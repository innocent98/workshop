import 'user_response.dart';

class LoginResponse {
  final String token;
  final UserResponse user;
  final String message;

  LoginResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String? ?? 'Login successful',
    );
  }
}
