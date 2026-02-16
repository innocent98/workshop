import 'dart:io';
import '../../data/models/responses/register_personal_info_response.dart';
import '../../data/models/responses/register_password_response.dart';
import '../../data/models/responses/send_otp_response.dart';
import '../../data/models/responses/verify_otp_response.dart';
import '../../data/models/responses/register_services_response.dart';
import '../../data/models/responses/login_response.dart';
import '../../data/models/responses/forgot_password_response.dart';
import '../../data/models/responses/verify_code_response.dart';

abstract class AuthRepository {
  Future<RegisterPersonalInfoResponse> registerPersonalInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String userType,
  });

  Future<RegisterPasswordResponse> registerPassword({
    required String userId,
    required String password,
    required String confirmPassword,
  });

  Future<SendOtpResponse> sendOtp({
    required String userId,
    required String email,
  });

  Future<VerifyOtpResponse> verifyOtp({
    required String userId,
    required String otp,
  });

  Future<RegisterServicesResponse> registerServices({
    required String userId,
    required String userType,
    required List<String> services,
  });

  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  });

  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  Future<ForgotPasswordResponse> sendPasswordResetCode({required String email});

  Future<VerifyCodeResponse> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> logout();
}
