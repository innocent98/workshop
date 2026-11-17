import 'dart:io';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/requests/register_personal_info_request.dart';
import '../models/requests/register_password_request.dart';
import '../models/requests/send_otp_request.dart';
import '../models/requests/verify_otp_request.dart';
import '../models/requests/register_services_request.dart';
import '../models/requests/login_request.dart';
import '../models/requests/forgot_password_send_code_request.dart';
import '../models/requests/verify_code_request.dart';
import '../models/requests/reset_password_request.dart';
import '../models/responses/register_personal_info_response.dart';
import '../models/responses/register_password_response.dart';
import '../models/responses/send_otp_response.dart';
import '../models/responses/verify_otp_response.dart';
import '../models/responses/register_services_response.dart';
import '../models/responses/login_response.dart';
import '../models/responses/forgot_password_response.dart';
import '../models/responses/verify_code_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<RegisterPersonalInfoResponse> registerPersonalInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String userType,
  }) async {
    final request = RegisterPersonalInfoRequest(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      userType: userType,
    );
    return await _remoteDataSource.registerPersonalInfo(request);
  }

  @override
  Future<RegisterPasswordResponse> registerPassword({
    required String userId,
    required String password,
    required String confirmPassword,
  }) async {
    final request = RegisterPasswordRequest(
      userId: userId,
      password: password,
      confirmPassword: confirmPassword,
    );
    return await _remoteDataSource.registerPassword(request);
  }

  @override
  Future<SendOtpResponse> sendOtp({
    required String userId,
    required String email,
  }) async {
    final request = SendOtpRequest(userId: userId, email: email);
    return await _remoteDataSource.sendOtp(request);
  }

  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    final request = VerifyOtpRequest(userId: userId, otpCode: otp);
    return await _remoteDataSource.verifyOtp(request);
  }

  @override
  Future<RegisterServicesResponse> registerServices({
    required String userId,
    required String userType,
    required List<String> services,
  }) async {
    final request = RegisterServicesRequest(
      userId: userId,
      userType: userType,
      services: services,
    );
    return await _remoteDataSource.registerServices(request);
  }

  @override
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    return await _remoteDataSource.uploadProfilePicture(
      userId: userId,
      imageFile: imageFile,
    );
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    return await _remoteDataSource.login(request);
  }

  @override
  Future<LoginResponse> googleSignIn({
    required String googleToken,
    String? userType,
  }) async {
    return await _remoteDataSource.googleSignIn(
      googleToken: googleToken,
      userType: userType,
    );
  }

  @override
  Future<ForgotPasswordResponse> sendPasswordResetCode({
    required String email,
  }) async {
    final request = ForgotPasswordSendCodeRequest(email: email);
    return await _remoteDataSource.sendPasswordResetCode(request);
  }

  @override
  Future<VerifyCodeResponse> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    final request = VerifyCodeRequest(email: email, code: code);
    return await _remoteDataSource.verifyPasswordResetCode(request);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = ResetPasswordRequest(
      email: email,
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    return await _remoteDataSource.resetPassword(request);
  }

  @override
  Future<void> logout() async {
    return await _remoteDataSource.logout();
  }

  @override
  Future<void> deleteAccount({String? password, String? googleToken}) async {
    return await _remoteDataSource.deleteAccount(
      password: password,
      googleToken: googleToken,
    );
  }
}
