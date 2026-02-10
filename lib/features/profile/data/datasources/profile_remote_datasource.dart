import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../artisan_profile/domain/models/portfolio_item.dart';
import '../../../services/domain/models/service.dart';

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

  Future<void> updateArtisanProfile({
    String? fullName,
    String? phoneNumber,
    String? bio,
    String? locationAddress,
    double? serviceRadiusKm,
    double? hourlyRateMin,
    double? hourlyRateMax,
    int? yearsOfExperience,
    String? specialization,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (fullName != null) data['full_name'] = fullName;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (bio != null) data['bio'] = bio;
      if (locationAddress != null) data['location_address'] = locationAddress;
      if (serviceRadiusKm != null) data['service_radius_km'] = serviceRadiusKm;
      if (hourlyRateMin != null) data['hourly_rate_min'] = hourlyRateMin;
      if (hourlyRateMax != null) data['hourly_rate_max'] = hourlyRateMax;
      if (yearsOfExperience != null) {
        data['years_of_experience'] = yearsOfExperience;
      }
      if (specialization != null) data['specialization'] = specialization;

      await _dio.put('/profiles/artisans/me', data: data);
    } on DioException catch (e) {
      throw _mapDioError(
        e,
        fallbackMessage: 'Failed to update artisan profile',
      );
    }
  }

  Future<List<PortfolioItem>> fetchMyPortfolio() async {
    try {
      final response = await _dio.get('/profiles/artisans/me/portfolio');
      final data = response.data;
      final items = data is List
          ? data
          : (data is Map<String, dynamic>
                ? (data['items'] as List? ?? [])
                : []);

      return items
          .whereType<Map<String, dynamic>>()
          .map(
            (json) => PortfolioItem(
              id: (json['id'] ?? '').toString(),
              title: (json['title'] ?? 'Untitled project').toString(),
              imageUrl: (json['image_url'] ?? '').toString(),
              description: json['description'] as String?,
              projectDate: json['project_date'] != null
                  ? DateTime.tryParse(json['project_date'].toString())
                  : null,
              displayOrder: (json['display_order'] as num?)?.toInt(),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to fetch portfolio');
    }
  }

  Future<void> addPortfolioItem({
    required File imageFile,
    String? title,
    String? description,
    int displayOrder = 0,
  }) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'display_order': displayOrder,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      await _dio.post('/profiles/artisans/me/portfolio', data: formData);
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to add portfolio item');
    }
  }

  Future<void> updatePortfolioItem({
    required int itemId,
    String? title,
    String? description,
    int? displayOrder,
  }) async {
    try {
      await _dio.put(
        '/profiles/artisans/me/portfolio/$itemId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (displayOrder != null) 'display_order': displayOrder,
        },
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to update portfolio item');
    }
  }

  Future<void> deletePortfolioItem(int itemId) async {
    try {
      await _dio.delete('/profiles/artisans/me/portfolio/$itemId');
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to delete portfolio item');
    }
  }

  Future<List<Service>> fetchMyArtisanServices() async {
    try {
      final response = await _dio.get('/profiles/artisans/me/services');
      final data = response.data;
      final items = data is List
          ? data
          : (data is Map<String, dynamic>
                ? (data['services'] as List? ?? [])
                : []);

      return items
          .whereType<Map<String, dynamic>>()
          .map(
            (json) => Service(
              id: (json['id'] ?? '').toString(),
              name: (json['name'] ?? '').toString(),
              description: json['description'] as String?,
              imageUrl: json['image'] as String?,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(
        e,
        fallbackMessage: 'Failed to fetch artisan services',
      );
    }
  }

  Future<void> updateMyArtisanServices(List<String> serviceIds) async {
    try {
      final parsedIds = serviceIds
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toList();

      await _dio.put(
        '/profiles/artisans/me/services',
        data: {'service_ids': parsedIds},
      );
    } on DioException catch (e) {
      throw _mapDioError(
        e,
        fallbackMessage: 'Failed to update artisan services',
      );
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
