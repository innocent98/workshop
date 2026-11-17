import '../../domain/models/artisan_verification.dart';
import '../../domain/models/verification_status.dart';

/// Wire model for `GET/POST /profiles/artisans/me/verification`.
///
/// Parsing is lenient: a missing or oddly-typed field falls back to a safe
/// default instead of throwing.
class VerificationResponse {
  final String? verificationStatus;
  final bool isVerified;
  final String? verifiedAt;
  final String? verificationMethod;
  final String? failureReason;
  final String? ninLast4;
  final int attemptsUsed;
  final int attemptsRemaining;
  final int maxAttempts;
  final int windowHours;
  final String? retryAvailableAt;

  const VerificationResponse({
    this.verificationStatus,
    this.isVerified = false,
    this.verifiedAt,
    this.verificationMethod,
    this.failureReason,
    this.ninLast4,
    this.attemptsUsed = 0,
    this.attemptsRemaining = 5,
    this.maxAttempts = 5,
    this.windowHours = 24,
    this.retryAvailableAt,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      verificationStatus: _string(json['verification_status']),
      isVerified: json['is_verified'] == true,
      verifiedAt: _string(json['verified_at']),
      verificationMethod: _string(json['verification_method']),
      failureReason: _string(json['failure_reason']),
      ninLast4: _string(json['nin_last4']),
      attemptsUsed: _int(json['attempts_used'], 0),
      attemptsRemaining: _int(json['attempts_remaining'], 5),
      maxAttempts: _int(json['max_attempts'], 5),
      windowHours: _int(json['window_hours'], 24),
      retryAvailableAt: _string(json['retry_available_at']),
    );
  }

  ArtisanVerification toDomain() {
    var status = VerificationStatus.fromApi(verificationStatus);
    // `is_verified` is the source of truth for the badge.
    if (isVerified) status = VerificationStatus.verified;

    return ArtisanVerification(
      status: status,
      isVerified: isVerified,
      verifiedAt: parseServerTime(verifiedAt),
      method: verificationMethod,
      failureReason: failureReason,
      ninLast4: ninLast4,
      attemptsUsed: attemptsUsed,
      attemptsRemaining: attemptsRemaining,
      maxAttempts: maxAttempts,
      windowHours: windowHours,
      retryAvailableAt: parseServerTime(retryAvailableAt),
    );
  }

  static String? _string(Object? v) => v is String && v.isNotEmpty ? v : null;

  static int _int(Object? v, int fallback) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}

/// Parses a server timestamp. A timestamp without a zone designator is assumed
/// to be UTC (the backend stores UTC) rather than the device's local time.
DateTime? parseServerTime(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
  return DateTime.tryParse(hasZone ? raw : '${raw}Z');
}
