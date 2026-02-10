import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

class InitializePaymentResult {
  final String paymentReference;
  final String authorizationUrl;

  const InitializePaymentResult({
    required this.paymentReference,
    required this.authorizationUrl,
  });
}

class VerifyPaymentResult {
  final bool paid;
  final String message;
  final String status;

  const VerifyPaymentResult({
    required this.paid,
    required this.message,
    required this.status,
  });
}

class PaymentRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<InitializePaymentResult> initializePayment({
    required int bookingId,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/initialize',
        data: {'booking_id': bookingId},
      );
      final data = response.data as Map<String, dynamic>;
      return InitializePaymentResult(
        paymentReference: data['payment_reference'] as String,
        authorizationUrl: data['authorization_url'] as String,
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to initialize payment');
    }
  }

  Future<VerifyPaymentResult> verifyPayment({
    required String paymentReference,
  }) async {
    try {
      final response = await _dio.get('/payments/verify/$paymentReference');
      final data = response.data as Map<String, dynamic>;
      return VerifyPaymentResult(
        paid: data['paid'] as bool? ?? false,
        message: data['message'] as String? ?? 'Payment verification completed',
        status: data['status'] as String? ?? 'unknown',
      );
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Failed to verify payment');
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
