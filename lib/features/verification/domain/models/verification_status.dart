/// Identity verification state of an artisan.
///
/// The backend sends `unverified | pending | verified | failed`. Anything else
/// (a value added later, null, wrong type) parses to [unknown] so an additive
/// backend change can never crash the app.
enum VerificationStatus {
  unverified,
  pending,
  verified,
  failed,
  unknown;

  static VerificationStatus fromApi(Object? raw) {
    if (raw is! String) return VerificationStatus.unknown;
    switch (raw.trim().toLowerCase()) {
      case 'unverified':
        return VerificationStatus.unverified;
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'failed':
        return VerificationStatus.failed;
      default:
        return VerificationStatus.unknown;
    }
  }
}
