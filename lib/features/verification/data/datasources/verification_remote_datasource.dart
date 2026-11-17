import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/models/verification_api_exception.dart';
import '../models/dojah_config_response.dart';
import '../models/start_verification_response.dart';
import '../models/verification_response.dart';

/// Talks to `/profiles/artisans/me/verification/*`.
///
/// Privacy: the NIN and selfie go to Dojah's widget, never through here. Only
/// the backend reference id is sent. Nothing is logged, cached or persisted.
class VerificationRemoteDataSource {
  static const String basePath = '/profiles/artisans/me/verification';
  static const String configPath = '$basePath/config';
  static const String startPath = '$basePath/start';
  static const String confirmPath = '$basePath/confirm';
  static const String statusPath = '$basePath/status';

  final Dio _dio;

  VerificationRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<DojahConfigResponse> getConfig() async {
    try {
      final response = await _dio.get(configPath);
      return DojahConfigResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _map(e, 'Failed to load verification settings');
    }
  }

  /// Burns one attempt. Never retried here or by any caller automatically.
  Future<StartVerificationResponse> start() async {
    try {
      final response = await _dio.post(startPath);
      return StartVerificationResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _map(e, 'Failed to start verification');
    }
  }

  Future<VerificationResponse> confirm(String referenceId) async {
    try {
      final response = await _dio.post(
        confirmPath,
        data: {'reference_id': referenceId},
      );
      return VerificationResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _map(e, 'Failed to confirm verification');
    }
  }

  Future<VerificationResponse> getStatus() async {
    try {
      final response = await _dio.get(statusPath);
      return VerificationResponse.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw _map(e, 'Failed to load verification status');
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
