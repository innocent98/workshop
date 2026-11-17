import 'models/artisan_booking.dart';

/// Mirrors the backend's `DisputeCompletionRequest.dispute_reason`
/// (`min_length=10, max_length=500`).
const int kDisputeReasonMinLength = 10;
const int kDisputeReasonMaxLength = 500;

/// Returns an error message, or `null` when [value] is an acceptable reason.
/// The text is trimmed first, matching what is actually sent to the backend.
String? validateDisputeReason(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Tell us what went wrong';
  if (text.length < kDisputeReasonMinLength) {
    return 'Please give at least $kDisputeReasonMinLength characters '
        '(${text.length}/$kDisputeReasonMinLength)';
  }
  if (text.length > kDisputeReasonMaxLength) {
    return 'Please keep it under $kDisputeReasonMaxLength characters';
  }
  return null;
}

/// A client can raise a dispute only on a completed job that they have not yet
/// confirmed or disputed, and only until the confirmation deadline.
bool canDisputeCompletion(ArtisanBooking booking, {DateTime? now}) {
  if (booking.status != ArtisanBookingStatus.completed) return false;
  if (booking.completionConfirmedByClientAt != null) return false;
  if (booking.completionDisputedAt != null) return false;
  final deadline = booking.completionConfirmationDeadlineAt;
  if (deadline != null && (now ?? DateTime.now()).isAfter(deadline)) {
    return false;
  }
  return true;
}
