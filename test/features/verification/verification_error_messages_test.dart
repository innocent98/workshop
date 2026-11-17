import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/verification/domain/models/verification_api_exception.dart';
import 'package:workchop/features/verification/domain/verification_error_messages.dart';

void main() {
  const contractCodes = [
    'already_verified',
    'attempts_exhausted',
    'verification_unavailable',
    'unknown_reference',
    'provider_error',
  ];

  group('code map', () {
    test('has a friendly message for every code in the contract', () {
      for (final code in contractCodes) {
        final message = verificationMessageForCode(code);
        expect(message, isNotNull, reason: code);
        expect(message, isNotEmpty, reason: code);
        expect(message, isNot(contains('_')), reason: '$code leaks the code');
      }
    });

    test('unknown or null code has no mapped message', () {
      expect(verificationMessageForCode('something_new'), isNull);
      expect(verificationMessageForCode(null), isNull);
    });

    test('dead codes from the old upload flow are gone', () {
      for (final code in [
        'invalid_nin',
        'invalid_image',
        'verification_in_progress',
      ]) {
        expect(verificationMessageForCode(code), isNull, reason: code);
      }
    });

    test('says what happened to the attempt / the verification', () {
      expect(
        verificationMessageForCode('verification_unavailable'),
        contains('not used'),
      );
      expect(
        verificationMessageForCode('provider_error'),
        contains("hasn't been lost"),
      );
    });
  });

  group('verificationErrorMessage', () {
    test('maps each code on an ApiException', () {
      for (final code in contractCodes) {
        final message = verificationErrorMessage(
          ApiException('backend text', 400, code),
        );
        expect(message, verificationErrorMessages[code], reason: code);
      }
    });

    test('offline gets its own copy', () {
      expect(
        verificationErrorMessage(NetworkException()),
        verificationOfflineMessage,
      );
      expect(verificationOfflineMessage, contains('offline'));
    });

    test('unauthorized asks the user to log in again', () {
      expect(
        verificationErrorMessage(UnauthorizedException()),
        verificationSessionExpiredMessage,
      );
    });

    test('403 string detail (client account) is mapped by status', () {
      expect(
        verificationErrorMessage(
          ApiException('Only artisans can access this endpoint', 403),
        ),
        verificationNotArtisanMessage,
      );
    });

    test('422 validation errors are not shown raw', () {
      expect(
        verificationErrorMessage(ApiException('Field required', 422)),
        verificationGenericMessage,
      );
    });

    test('429, 502 and 503 without a code still map by status', () {
      expect(
        verificationErrorMessage(ApiException('x', 502)),
        verificationErrorMessages['provider_error'],
      );
      expect(
        verificationErrorMessage(ApiException('x', 429)),
        verificationErrorMessages['attempts_exhausted'],
      );
      expect(
        verificationErrorMessage(ApiException('x', 503)),
        verificationErrorMessages['verification_unavailable'],
      );
    });

    test('unknown code falls back to the backend message', () {
      expect(
        verificationErrorMessage(ApiException('Try later please', 400, 'new')),
        'Try later please',
      );
    });

    test('500 and non-API errors use the generic copy', () {
      expect(
        verificationErrorMessage(ApiException('Internal Server Error', 500)),
        verificationGenericMessage,
      );
      expect(
        verificationErrorMessage(StateError('boom')),
        verificationGenericMessage,
      );
    });

    test('attempts_exhausted includes the retry time when known', () {
      final now = DateTime(2026, 11, 17, 10, 0);
      final message = verificationErrorMessage(
        VerificationApiException(
          message: 'x',
          statusCode: 429,
          code: 'attempts_exhausted',
          retryAvailableAt: DateTime(2026, 11, 17, 15, 45),
        ),
        now: now,
      );
      expect(message, contains('at 3:45 PM'));
    });

    test('attempts_exhausted without a time uses the plain copy', () {
      expect(
        verificationErrorMessage(
          VerificationApiException(
            message: 'x',
            statusCode: 429,
            code: 'attempts_exhausted',
          ),
        ),
        verificationErrorMessages['attempts_exhausted'],
      );
    });
  });

  group('flow copy', () {
    test('closed early and widget error say the attempt is used', () {
      expect(verificationClosedEarlyMessage(3), contains('has been used'));
      expect(verificationClosedEarlyMessage(3), contains('3 attempts left'));
      expect(verificationClosedEarlyMessage(1), contains('1 attempt left'));
      expect(verificationClosedEarlyMessage(null), isNot(contains('left')));
      expect(verificationWidgetIncompleteMessage(2), contains('has been used'));
    });

    test('not-configured and camera copy say no attempt was used', () {
      expect(verificationNotConfiguredMessage, contains('No attempt'));
      expect(verificationCameraDeniedMessage, contains('not used'));
      expect(verificationCameraBlockedMessage, contains('Settings'));
    });
  });

  group('formatRetryTime', () {
    final now = DateTime(2026, 11, 17, 10, 0);

    test('same day, tomorrow and later', () {
      expect(
        formatRetryTime(DateTime(2026, 11, 17, 0, 5), now: now),
        'at 12:05 AM',
      );
      expect(
        formatRetryTime(DateTime(2026, 11, 17, 12, 30), now: now),
        'at 12:30 PM',
      );
      expect(
        formatRetryTime(DateTime(2026, 11, 18, 9, 0), now: now),
        'tomorrow at 9:00 AM',
      );
      expect(
        formatRetryTime(DateTime(2026, 11, 20, 21, 15), now: now),
        'on 20 Nov at 9:15 PM',
      );
    });
  });
}
