import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await _dio.get('/services');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout. Please try again.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'An error occurred. Please try again.';
      if (data is Map<String, dynamic>) {
        message = data['detail'] as String? ??
            data['message'] as String? ??
            message;
      }

      if (statusCode == 401) {
        return UnauthorizedException(message);
      }

      return ApiException(message, statusCode);
    }

    return NetworkException();
  }
}
