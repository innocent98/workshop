import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Converts a [DioException] into one of the domain exceptions
/// ([NetworkException], [UnauthorizedException], [ApiException]) so the UI never
/// has to show a raw `DioException [bad response]: ...` string.
///
/// Understands the shapes FastAPI returns:
/// * `{"detail": "text"}`
/// * `{"detail": {"code": "x", "message": "text"}}`
/// * `{"detail": [{"msg": "text", ...}]}` (422 validation errors)
/// * `{"message": "text"}`
Exception mapDioError(
  DioException error, {
  String fallbackMessage = 'Something went wrong. Please try again.',
}) {
  // The auth interceptor already converted 401s into a typed error.
  final inner = error.error;
  if (inner is UnauthorizedException) return inner;
  if (inner is ApiException || inner is NetworkException) {
    return inner as Exception;
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return NetworkException();
    default:
      break;
  }

  final status = error.response?.statusCode;
  if (status == 401) return UnauthorizedException();

  final parsed = parseErrorBody(error.response?.data);
  if (parsed != null) {
    return ApiException(parsed.message, status, parsed.code);
  }
  return ApiException(fallbackMessage, status);
}

/// A message plus optional machine-readable code extracted from an error body.
class ParsedErrorBody {
  final String message;
  final String? code;
  const ParsedErrorBody(this.message, this.code);
}

ParsedErrorBody? parseErrorBody(Object? data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is String && detail.trim().isNotEmpty) {
    return ParsedErrorBody(detail, null);
  }
  if (detail is Map) {
    final message = detail['message'];
    final code = detail['code'];
    if (message is String && message.trim().isNotEmpty) {
      return ParsedErrorBody(message, code is String ? code : null);
    }
    if (code is String) return ParsedErrorBody(code, code);
  }
  if (detail is List && detail.isNotEmpty) {
    final first = detail.first;
    if (first is Map && first['msg'] is String) {
      return ParsedErrorBody(first['msg'] as String, null);
    }
  }
  final message = data['message'];
  if (message is String && message.trim().isNotEmpty) {
    return ParsedErrorBody(
      message,
      data['code'] is String ? data['code'] as String : null,
    );
  }
  return null;
}

/// Text that is safe to show to a user for any caught error. Never returns a
/// raw `DioException ...` string or a stack-trace-looking message.
String userMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is DioException) {
    return userMessage(
      mapDioError(error, fallbackMessage: fallback),
      fallback: fallback,
    );
  }
  if (error is ApiException) return error.message;
  if (error is NetworkException) return error.message;
  if (error is UnauthorizedException) return error.message;
  if (error is FormatException) return fallback;
  if (error is Exception) {
    final text = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    final looksTechnical =
        text.contains('DioException') ||
        text.contains('Instance of') ||
        text.contains('type \'') ||
        text.length > 160;
    if (text.trim().isNotEmpty && !looksTechnical) return text.trim();
  }
  return fallback;
}

/// True when [error] means the device is offline or the server is unreachable.
bool isOfflineError(Object error) {
  if (error is NetworkException) return true;
  if (error is DioException) {
    return mapDioError(error) is NetworkException;
  }
  return false;
}
