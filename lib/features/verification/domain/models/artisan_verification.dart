import 'verification_status.dart';

/// The artisan's current identity-verification state, as returned by
/// `GET/POST /profiles/artisans/me/verification`.
///
/// Never carries the NIN itself: the backend only exposes [ninLast4].
class ArtisanVerification {
  final VerificationStatus status;
  final bool isVerified;
  final DateTime? verifiedAt;

  /// `dojah | admin | legacy`, or null.
  final String? method;

  /// Human-readable reason for a `failed` status. Shown to the user verbatim.
  final String? failureReason;
  final String? ninLast4;
  final int attemptsUsed;
  final int attemptsRemaining;
  final int maxAttempts;
  final int windowHours;

  /// Non-null only when [attemptsRemaining] is 0.
  final DateTime? retryAvailableAt;

  const ArtisanVerification({
    required this.status,
    this.isVerified = false,
    this.verifiedAt,
    this.method,
    this.failureReason,
    this.ninLast4,
    this.attemptsUsed = 0,
    this.attemptsRemaining = 5,
    this.maxAttempts = 5,
    this.windowHours = 24,
    this.retryAvailableAt,
  });

  bool get isPending => status == VerificationStatus.pending;

  /// All attempts for the rolling window are used up.
  bool get isLockedOut => !isVerified && attemptsRemaining <= 0;
}
