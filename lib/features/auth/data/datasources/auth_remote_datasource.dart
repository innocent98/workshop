import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
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

class AuthRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<RegisterPersonalInfoResponse> registerPersonalInfo(
    RegisterPersonalInfoRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register/personal-info',
        data: request.toJson(),
      );
      return RegisterPersonalInfoResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<RegisterPasswordResponse> registerPassword(
    RegisterPasswordRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register/password',
        data: request.toJson(),
      );
      return RegisterPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp',
        data: request.toJson(),
      );
      return SendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: request.toJson(),
      );
      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<RegisterServicesResponse> registerServices(
    RegisterServicesRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register/services',
        data: request.toJson(),
      );
      return RegisterServicesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'user_id': userId,
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        '/auth/register/profile-picture',
        data: formData,
      );
      return response.data['profile_picture_url'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ForgotPasswordResponse> sendPasswordResetCode(
    ForgotPasswordSendCodeRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/send-code',
        data: request.toJson(),
      );
      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<VerifyCodeResponse> verifyPasswordResetCode(
    VerifyCodeRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/verify-code',
        data: request.toJson(),
      );
      return VerifyCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await _dio.post(
        '/auth/forgot-password/reset',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    // print('DioException caught: ${error.error}, ${error.message}, type: ${error.type}, response: ${error.response?.data}');
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout. Please try again.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    // If we have a response from the server (e.g., 400, 401, 429, 500 errors)
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'An error occurred. Please try again.';

      if (data is String) {
        message = data;
      } else if (data is Map<String, dynamic>) {
        // Check if detail is a List (validation errors from FastAPI/Pydantic)
        if (data['detail'] is List && (data['detail'] as List).isNotEmpty) {
          final firstError = (data['detail'] as List).first;
          if (firstError is Map<String, dynamic> && firstError['msg'] != null) {
            message = firstError['msg'] as String;
          }
        } else {
          // Standard error message handling
          message = data['message'] as String? ??
              data['detail'] as String? ??
              data['error'] as String? ??
              message;
        }
      }

      if (statusCode == 401) {
        return UnauthorizedException(message);
      }

      return ApiException(message, statusCode);
    }

    // If we have an error but no response (e.g., parsing error, unknown error)
    if (error.error != null) {
      final data = error.error;

      if (data is String) {
        return ApiException(data);
      }

      String message = 'An error occurred. Please try again.';
      if (data is Map<String, dynamic>) {
        message = data['detail'] as String? ??
            data['message'] as String? ??
            message;
      } else {
        // For other types (exceptions, objects), convert to string
        message = data.toString();
      }

      return ApiException(message);
    }

    return NetworkException();
  }
}
