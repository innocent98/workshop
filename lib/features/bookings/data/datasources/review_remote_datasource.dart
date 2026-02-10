import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

class ReviewRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<void> createReview({
    required int bookingId,
    required double rating,
    String? reviewText,
    bool isAnonymous = false,
  }) async {
    try {
      await _dio.post(
        '/reviews',
        data: {
          'booking_id': bookingId,
          'rating': rating,
          if (reviewText != null && reviewText.trim().isNotEmpty)
            'review_text': reviewText.trim(),
          'is_anonymous': isAnonymous,
        },
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to submit review');
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
