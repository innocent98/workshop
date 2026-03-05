import 'user_response.dart';

class LoginResponse {
  final String token;
  final UserResponse user;
  final String message;
  final bool isNewUser;

  LoginResponse({
    required this.token,
    required this.user,
    required this.message,
    this.isNewUser = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String? ?? 'Login successful',
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}
