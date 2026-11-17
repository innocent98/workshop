import '../../../../core/network/api_exception.dart';

/// An [ApiException] from the verification endpoints that also carries the
/// `retry_available_at` timestamp of an `attempts_exhausted` (429) response.
class VerificationApiException extends ApiException {
  final DateTime? retryAvailableAt;

  VerificationApiException({
    required String message,
    int? statusCode,
    String? code,
    this.retryAvailableAt,
  }) : super(message, statusCode, code);
}
