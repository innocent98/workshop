import 'dart:async';

import 'package:dio/dio.dart';
import '../services/token_storage_service.dart';
import '../services/auth_session_service.dart';
import 'api_exception.dart';
import 'dio_error_mapper.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage = TokenStorageService();
  static const _nonCritical401Paths = <String>[
    '/notifications/devices/register',
    '/notifications/devices/unregister',
    // A 401 here means bad credentials (or a deleted account), not an expired
    // session. Treating it as a forced logout rebuilt the login route and wiped
    // the error snackbar, so the user saw no feedback at all.
    '/auth/login',
    '/auth/google',
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
    // `detail` may be a string or a `{code, message}` object (e.g. the account
    // deletion errors); a blind `as String?` cast here used to throw and hide
    // the real reason behind a generic message.
    errorMessage = parseErrorBody(err.response?.data)?.message ?? errorMessage;

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
