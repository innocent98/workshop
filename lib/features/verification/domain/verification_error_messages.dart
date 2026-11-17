import '../../../core/network/api_exception.dart';
import 'models/verification_api_exception.dart';

/// Backend error `code` -> friendly, user-impact-first copy.
///
/// Codes come from `detail.code` on the verification endpoints.
const Map<String, String> verificationErrorMessages = {
  'invalid_nin':
      "That NIN doesn't look right. It must be exactly 11 digits. "
      'Check it and try again.',
  'invalid_image':
      "We couldn't use that selfie. Retake it in good light with your face "
      'clearly visible. This attempt was not counted.',
  'already_verified':
      "You're already verified. There's nothing more to do here.",
  'verification_in_progress':
      "We're already checking your details. This usually takes a few "
      'seconds, so hang tight.',
  'attempts_exhausted':
      "You've used all your verification attempts for now. Try again later "
      'or contact support and we can verify you manually.',
  'verification_unavailable':
      "Our verification service isn't available right now. Your attempt was "
      'not counted. Please try again in a little while.',
};

const String verificationOfflineMessage =
    "You're offline, so we couldn't reach the server. Your details were not "
    'saved. Check your connection and try again.';

const String verificationSessionExpiredMessage =
    'Your session has expired. Please log in again.';

const String verificationGenericMessage =
    'Something went wrong on our side. Please try again.';

const String verificationNotArtisanMessage =
    'Identity verification is only available to artisan accounts.';

const String verificationFileTooLargeMessage =
    'That selfie is too large. Retake it and try again.';

const String verificationMissingFieldMessage =
    'Enter your 11-digit NIN and take a selfie to continue.';

/// Message for a known backend error code, or null if the code is unknown.
String? verificationMessageForCode(String? code) =>
    code == null ? null : verificationErrorMessages[code];

/// Friendly text for any error thrown by the verification layer. Never shows a
/// raw exception string.
String verificationErrorMessage(Object error, {DateTime? now}) {
  if (error is NetworkException) return verificationOfflineMessage;
  if (error is UnauthorizedException) return verificationSessionExpiredMessage;

  if (error is ApiException) {
    final known = verificationMessageForCode(error.code);
    if (known != null) {
      if (error.code == 'attempts_exhausted' &&
          error is VerificationApiException &&
          error.retryAvailableAt != null) {
        final when = formatRetryTime(error.retryAvailableAt!, now: now);
        return "You've used all your verification attempts for now. You can "
            'try again $when, or contact support and we can verify you '
            'manually.';
      }
      return known;
    }
    switch (error.statusCode) {
      case 403:
        return verificationNotArtisanMessage;
      case 413:
        return verificationFileTooLargeMessage;
      case 422:
        return verificationMissingFieldMessage;
      case 429:
        return verificationErrorMessages['attempts_exhausted']!;
      case 503:
        return verificationErrorMessages['verification_unavailable']!;
    }
    // Unknown code: the backend's own message is written for users.
    if (error.message.trim().isNotEmpty && error.statusCode != 500) {
      return error.message;
    }
  }
  return verificationGenericMessage;
}

/// "at 3:45 PM", "tomorrow at 3:45 PM" or "on 12 Nov at 3:45 PM", in the
/// device's local time.
String formatRetryTime(DateTime retryAt, {DateTime? now}) {
  final local = retryAt.toLocal();
  final current = (now ?? DateTime.now()).toLocal();

  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final meridiem = local.hour >= 12 ? 'PM' : 'AM';
  final time = '$hour12:$minute $meridiem';

  final today = DateTime(current.year, current.month, current.day);
  final target = DateTime(local.year, local.month, local.day);
  final days = target.difference(today).inDays;

  if (days <= 0) return 'at $time';
  if (days == 1) return 'tomorrow at $time';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return 'on ${local.day} ${months[local.month - 1]} at $time';
}
