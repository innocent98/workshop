import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class BookingRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<void> createBooking({
    required String artisanId,
    required List<int> serviceIds,
    required DateTime jobDateUtc,
    required String jobAddress,
    required double jobLatitude,
    required double jobLongitude,
    required double budgetMin,
    required double budgetMax,
    String? jobDescription,
  }) async {
    try {
      await _dio.post(
        '/bookings',
        data: {
          'artisan_id': artisanId,
          'service_ids': serviceIds,
          'service_id': serviceIds.first,
          if (jobDescription != null && jobDescription.trim().isNotEmpty)
            'job_description': jobDescription.trim(),
          'job_date': jobDateUtc.toIso8601String(),
          'job_address': jobAddress,
          'job_latitude': jobLatitude,
          'job_longitude': jobLongitude,
          'budget_min': budgetMin,
          'budget_max': budgetMax,
        },
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to create booking');
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
