import 'package:dio/dio.dart';
import '../services/token_storage_service.dart';
import 'api_exception.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage = TokenStorageService();
  static const _nonCritical401Paths = <String>[
    '/notifications/devices/register',
    '/notifications/devices/unregister',
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
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      final shouldPreserveToken = _nonCritical401Paths.any(
        requestPath.contains,
      );

      if (!shouldPreserveToken) {
        _tokenStorage.deleteToken();
      }

      // Extract error message from response
      String errorMessage = 'Unauthorized. Please login again.';
      if (err.response?.data is Map<String, dynamic>) {
        final data = err.response!.data as Map<String, dynamic>;
        errorMessage =
            data['detail'] as String? ??
            data['message'] as String? ??
            errorMessage;
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: UnauthorizedException(errorMessage),
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
