import 'package:dio/dio.dart';
import '../services/token_storage_service.dart';
import 'api_exception.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage = TokenStorageService();

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
      _tokenStorage.deleteToken();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: UnauthorizedException(),
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
