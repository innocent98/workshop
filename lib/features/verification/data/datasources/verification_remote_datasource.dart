import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/models/verification_api_exception.dart';
import '../models/verification_response.dart';

/// Talks to `/profiles/artisans/me/verification`.
///
/// Privacy: the NIN and selfie only ever live inside the single multipart
/// request built here. Nothing is logged, cached or persisted.
class VerificationRemoteDataSource {
  static const String path = '/profiles/artisans/me/verification';

  /// The submit call is synchronous on the backend (the provider is called
  /// inside the request, typically 2-8 s), so it gets more room than the
  /// app-wide 30 s default.
  static const Duration submitTimeout = Duration(seconds: 45);

  final Dio _dio;

  VerificationRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<VerificationResponse> getVerification() async {
    try {
      final response = await _dio.get(path);
      return VerificationResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _map(e, 'Failed to load verification status');
    }
  }

  Future<VerificationResponse> submitVerification({
    required String nin,
    required File selfie,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nin': nin,
        'selfie': await MultipartFile.fromFile(
          selfie.path,
          filename: 'selfie.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          sendTimeout: submitTimeout,
          receiveTimeout: submitTimeout,
        ),
      );
      return VerificationResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _map(e, 'Failed to submit verification');
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException('Unexpected response from the server');
  }

  Exception _map(DioException error, String fallback) {
    final mapped = mapDioError(error, fallbackMessage: fallback);
    if (mapped is ApiException && mapped.code == 'attempts_exhausted') {
      return VerificationApiException(
        message: mapped.message,
        statusCode: mapped.statusCode,
        code: mapped.code,
        retryAvailableAt: _retryAvailableAt(error.response?.data),
      );
    }
    return mapped;
  }

  DateTime? _retryAvailableAt(Object? body) {
    if (body is! Map) return null;
    final detail = body['detail'];
    final raw = detail is Map ? detail['retry_available_at'] : null;
    return raw is String ? parseServerTime(raw) : null;
  }
}
