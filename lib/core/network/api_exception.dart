class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Machine-readable error code when the backend provides one
  /// (e.g. `{"detail": {"code": "...", "message": "..."}}`).
  final String? code;

  ApiException(this.message, [this.statusCode, this.code]);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException([
    this.message = 'Network error occurred. Please check your connection.',
  ]);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized. Please login again.']);

  @override
  String toString() => message;
}
