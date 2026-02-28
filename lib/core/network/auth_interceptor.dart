import 'dart:async';

import 'package:dio/dio.dart';
import '../services/token_storage_service.dart';
import '../services/auth_session_service.dart';
import 'api_exception.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage = TokenStorageService();
  static const _nonCritical401Paths = <String>[
    '/notifications/devices/register',
    '/notifications/devices/unregister',
  ];
  static const _authFailureHints = <String>[
    'not authenticated',
    'not authorized',
    'invalid token',
    'credentials',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;

    String errorMessage = 'Unauthorized. Please login again.';
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      errorMessage =
          data['detail'] as String? ??
          data['message'] as String? ??
          errorMessage;
    }

    final shouldPreserveToken = _nonCritical401Paths.any(requestPath.contains);
    final lowerMessage = errorMessage.toLowerCase();
    final looksLikeAuthFailure = _authFailureHints.any(lowerMessage.contains);
    final shouldForceLogout =
        !shouldPreserveToken &&
        (statusCode == 401 || (statusCode == 403 && looksLikeAuthFailure));

    if (shouldForceLogout) {
      unawaited(AuthSessionService.instance.forceLogout(errorMessage));
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: UnauthorizedException(errorMessage),
        ),
      );
      return;
    }

    if (statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: UnauthorizedException(errorMessage),
        ),
      );
      return;
    }

    handler.next(err);
  }
}
