import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/network/dio_client.dart';
import '../models/artisan_booking_response_model.dart';
import '../models/artisan_booking_stats_response_model.dart';

class ArtisanBookingsRemoteDataSource {
  final Dio _dio = DioClient().dio;
  final Logger _logger = Logger();

  Future<ArtisanBookingListResponseModel> listBookings({
    String? statusFilter,
  }) async {
    try {
      final response = await _dio.get(
        '/bookings',
        queryParameters: {
          if (statusFilter != null && statusFilter.isNotEmpty)
            'status_filter': statusFilter,
          'page': 1,
          'page_size': 100,
        },
      );

      return ArtisanBookingListResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to list artisan bookings: ${e.message}');
      rethrow;
    }
  }

  Future<ArtisanBookingResponseModel> getBooking(int bookingId) async {
    try {
      final response = await _dio.get('/bookings/$bookingId');
      return ArtisanBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to fetch booking $bookingId: ${e.message}');
      rethrow;
    }
  }

  Future<ArtisanBookingStatsResponseModel> getBookingStats() async {
    try {
      final response = await _dio.get('/bookings/stats');
      return ArtisanBookingStatsResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to fetch booking stats: ${e.message}');
      rethrow;
    }
  }

  Future<ArtisanBookingResponseModel> acceptBooking({
    required int bookingId,
    required double agreedAmount,
  }) async {
    try {
      final response = await _dio.patch(
        '/bookings/$bookingId/accept',
        data: {'agreed_amount': agreedAmount},
      );
      return ArtisanBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to accept booking $bookingId: ${e.message}');
      rethrow;
    }
  }

  Future<ArtisanBookingResponseModel> rejectBooking({
    required int bookingId,
    required String rejectionReason,
  }) async {
    try {
      final response = await _dio.patch(
        '/bookings/$bookingId/reject',
        data: {'rejection_reason': rejectionReason},
      );
      return ArtisanBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to reject booking $bookingId: ${e.message}');
      rethrow;
    }
  }

  Future<ArtisanBookingResponseModel> startBooking({
    required int bookingId,
  }) async {
    try {
      final response = await _dio.patch('/bookings/$bookingId/start');
      return ArtisanBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to start booking $bookingId: ${e.message}');
      rethrow;
    }
  }

  Future<ArtisanBookingResponseModel> completeBooking({
    required int bookingId,
    String? completionNotes,
    List<String>? completionImages,
  }) async {
    try {
      final response = await _dio.patch(
        '/bookings/$bookingId/complete',
        data: {
          if (completionNotes != null && completionNotes.isNotEmpty)
            'completion_notes': completionNotes,
          if (completionImages != null && completionImages.isNotEmpty)
            'completion_images': completionImages,
        },
      );
      return ArtisanBookingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to complete booking $bookingId: ${e.message}');
      rethrow;
    }
  }
}
