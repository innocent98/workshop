import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.headers,
      ),
    );

    _dio.interceptors.add(AuthInterceptor());

    // Bodies are never logged: requests carry passwords, NINs and selfies and
    // responses carry personal data. Only method/url/status are logged, and
    // only outside production builds.
    if (kDebugMode && !ApiConfig.isProd) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (obj) => _logger.d(obj),
        ),
      );
    }
  }
}
