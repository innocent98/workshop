import '../../../core/network/api_exception.dart';
import 'models/verification_api_exception.dart';

/// Backend error `code` -> friendly, user-impact-first copy.
///
/// Codes come from `detail.code` on the verification endpoints.
const Map<String, String> verificationErrorMessages = {
  'already_verified':
      "You're already verified. There's nothing more to do here.",
  'attempts_exhausted':
      "You've used all your verification attempts for now. Try again later "
      'or contact support and we can verify you manually.',
  'verification_unavailable':
      "Verification isn't available right now. Your attempt was not used. "
      'Please try again in a little while.',
  'unknown_reference':
      "We couldn't find that verification. Start a new one when you're ready.",
  'provider_error':
      "We couldn't reach our verification partner just now. Your "
      "verification hasn't been lost, so we'll keep checking.",
};

const String verificationOfflineMessage =
    "You're offline, so we couldn't reach the server. Check your connection "
    'and try again.';

const String verificationSessionExpiredMessage =
    'Your session has expired. Please log in again.';

const String verificationGenericMessage =
    'Something went wrong on our side. Please try again.';

const String verificationNotArtisanMessage =
    'Identity verification is only available to artisan accounts.';

const String verificationNotConfiguredMessage =
    "Identity verification isn't available yet. We're setting it up, so "
    'please check back soon. No attempt was used.';

const String verificationCameraDeniedMessage =
    'We need camera access to take your live selfie. Turn it on and try '
    'again. Your attempt was not used.';

const String verificationCameraBlockedMessage =
    'Camera access is turned off for Workchop. Open Settings to turn it on, '
    'then try again. Your attempt was not used.';

/// The widget reported an error before finishing. The attempt is spent.
String verificationWidgetIncompleteMessage(int? attemptsRemaining) =>
    "We couldn't finish your verification. That attempt has been used"
    '${_attemptsSuffix(attemptsRemaining)}. Please try again.';

/// The user closed the widget early. Not an error, but the attempt is spent.
String verificationClosedEarlyMessage(int? attemptsRemaining) =>
    'You closed verification before finishing. That attempt has been used'
    '${_attemptsSuffix(attemptsRemaining)}.';

String _attemptsSuffix(int? remaining) {
  if (remaining == null) return '';
  if (remaining == 1) return ' (1 attempt left)';
  return ' ($remaining attempts left)';
}

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
      case 422:
        return verificationGenericMessage;
      case 429:
        return verificationErrorMessages['attempts_exhausted']!;
      case 502:
        return verificationErrorMessages['provider_error']!;
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
