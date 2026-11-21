import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';

/// Backend codes for `POST /reviews/{id}/report` (captured live: 21, 22, 23, 26).
class ReviewReportCodes {
  static const alreadyReported = 'already_reported';
  static const ownReview = 'cannot_report_own_review';
  static const notFound = 'review_not_found';
  static const rateLimited = 'report_rate_limited';
}

const String _fallback = "Couldn't send your report. Please try again.";

/// Turns a failed report call into an [ApiException] carrying a user-friendly
/// message (and the backend `code`/status so the UI can tell "already
/// reported" apart from a real failure). Network and auth failures keep their
/// own typed exceptions.
Exception mapReviewReportError(DioException error) {
  final mapped = mapDioError(error, fallbackMessage: _fallback);
  if (mapped is! ApiException) return mapped;

  final status = mapped.statusCode;
  final code = mapped.code;

  if (status == 409 || code == ReviewReportCodes.alreadyReported) {
    return ApiException(
      "You've already reported this review.",
      409,
      ReviewReportCodes.alreadyReported,
    );
  }
  if (code == ReviewReportCodes.ownReview) {
    return ApiException("You can't report your own review.", status, code);
  }
  if (status == 404 || code == ReviewReportCodes.notFound) {
    return ApiException(
      'This review is no longer available.',
      404,
      ReviewReportCodes.notFound,
    );
  }
  if (status == 429 || code == ReviewReportCodes.rateLimited) {
    // The per-user cap's message is already user-facing; the per-IP 429 body
    // was not captured, so anything else gets a generic "slow down".
    final message = code == ReviewReportCodes.rateLimited
        ? mapped.message
        : "You've sent too many reports. Please try again later.";
    return ApiException(message, 429, code ?? ReviewReportCodes.rateLimited);
  }
  if (status == 403) {
    return ApiException('You need to sign in to report a review.', 403, code);
  }
  // 422 and anything unexpected: never show a raw validation/server string.
  return ApiException(_fallback, status, code);
}
