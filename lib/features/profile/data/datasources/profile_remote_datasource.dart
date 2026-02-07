import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

class ProfileRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<String> updateProfilePicture(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.put(
        '/profiles/me/profile-picture',
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      return data['profile_picture_url'] as String;
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to update profile photo');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to change password');
    }
  }

  Exception _mapDioError(
    DioException error, {
    required String fallbackMessage,
  }) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    if (error.response?.statusCode == 401) {
      return UnauthorizedException();
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];
      if (detail is String && detail.isNotEmpty) {
        return ApiException(detail, error.response?.statusCode);
      }
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return ApiException(message, error.response?.statusCode);
      }
    }

    return ApiException(fallbackMessage, error.response?.statusCode);
  }
}
