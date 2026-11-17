import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/artisan_profile/data/models/artisan_profile_response_model.dart';
import 'package:workchop/features/verification/data/models/dojah_config_response.dart';
import 'package:workchop/features/verification/data/models/start_verification_response.dart';
import 'package:workchop/features/verification/data/models/verification_response.dart';
import 'package:workchop/features/verification/domain/models/verification_status.dart';

// Shapes copied from the live captures in
// docs/fe-captures/verification-admin (backend repo), placeholder values only.
Map<String, dynamic> _body({
  String status = 'unverified',
  bool isVerified = false,
  String? verifiedAt,
  String? method,
  String? failureReason,
  String? nin4,
  String? ref,
  int used = 0,
  int remaining = 5,
  String? retryAt,
}) => {
  'verification_status': status,
  'is_verified': isVerified,
  'verified_at': verifiedAt,
  'verification_method': method,
  'failure_reason': failureReason,
  'nin_last4': nin4,
  'reference_id': ref,
  'attempts_used': used,
  'attempts_remaining': remaining,
  'max_attempts': 5,
  'window_hours': 24,
  'retry_available_at': retryAt,
};

void main() {
  group('VerificationResponse', () {
    test('unverified', () {
      final v = VerificationResponse.fromJson(_body()).toDomain();
      expect(v.status, VerificationStatus.unverified);
      expect(v.isVerified, isFalse);
      expect(v.verifiedAt, isNull);
      expect(v.method, isNull);
      expect(v.failureReason, isNull);
      expect(v.attemptsRemaining, 5);
      expect(v.maxAttempts, 5);
      expect(v.windowHours, 24);
      expect(v.isLockedOut, isFalse);
    });

    test('pending', () {
      final v = VerificationResponse.fromJson(
        _body(status: 'pending', used: 1, remaining: 4),
      ).toDomain();
      expect(v.status, VerificationStatus.pending);
      expect(v.isPending, isTrue);
      expect(v.attemptsUsed, 1);
    });

    test('verified (dojah)', () {
      final v = VerificationResponse.fromJson(
        _body(
          status: 'verified',
          isVerified: true,
          verifiedAt: '2026-11-17T10:00:00Z',
          method: 'dojah',
          nin4: '1117',
          ref: 'WC-NIN-795e18bb751cece1',
          used: 3,
          remaining: 4,
        ),
      ).toDomain();
      expect(v.status, VerificationStatus.verified);
      expect(v.isVerified, isTrue);
      expect(v.method, 'dojah');
      expect(v.ninLast4, '1117');
      expect(v.referenceId, 'WC-NIN-795e18bb751cece1');
      expect(v.verifiedAt, DateTime.utc(2026, 11, 17, 10));
    });

    test('is_verified wins over a stale status string', () {
      final v = VerificationResponse.fromJson(
        _body(status: 'unverified', isVerified: true, method: 'legacy'),
      ).toDomain();
      expect(v.status, VerificationStatus.verified);
      expect(v.method, 'legacy');
    });

    test('failed keeps the reason verbatim', () {
      const reason = 'Your selfie did not match the photo on your NIN.';
      final v = VerificationResponse.fromJson(
        _body(status: 'failed', failureReason: reason, used: 2, remaining: 3),
      ).toDomain();
      expect(v.status, VerificationStatus.failed);
      expect(v.failureReason, reason);
      expect(v.attemptsRemaining, 3);
      expect(v.isLockedOut, isFalse);
    });

    test('failed with no attempts left is locked out with a retry time', () {
      final v = VerificationResponse.fromJson(
        _body(
          status: 'failed',
          failureReason: 'No match',
          used: 5,
          remaining: 0,
          retryAt: '2026-11-18T09:30:00+00:00',
        ),
      ).toDomain();
      expect(v.isLockedOut, isTrue);
      expect(v.retryAvailableAt, DateTime.utc(2026, 11, 18, 9, 30));
    });

    test('timestamps without a zone are read as UTC', () {
      expect(
        parseServerTime('2026-11-18T09:30:00'),
        DateTime.utc(2026, 11, 18, 9, 30),
      );
      expect(parseServerTime(null), isNull);
      expect(parseServerTime('not a date'), isNull);
    });

    test('empty or odd bodies fall back to safe defaults', () {
      final v = VerificationResponse.fromJson({
        'verification_status': 42,
        'attempts_remaining': '3',
        'max_attempts': null,
      }).toDomain();
      expect(v.status, VerificationStatus.unknown);
      expect(v.attemptsRemaining, 3);
      expect(v.maxAttempts, 5);
      expect(v.windowHours, 24);
      expect(VerificationResponse.fromJson({}).toDomain().isLockedOut, isFalse);
    });
  });

  group('config and start responses', () {
    test('config (capture 04)', () {
      final c = DojahConfigResponse.fromJson({
        'configured': true,
        'app_id': 'capture-app-id',
        'public_key': 'capture-public-key',
        'widget_id': 'capture-nin-widget',
        'environment': 'sandbox',
      }).toDomain();
      expect(c.configured, isTrue);
      expect(c.isUsable, isTrue);
      expect(c.widgetId, 'capture-nin-widget');
      expect(c.environment, 'sandbox');
    });

    test('configured:false with null ids is not usable', () {
      final c = DojahConfigResponse.fromJson({
        'configured': false,
        'app_id': null,
        'public_key': null,
        'widget_id': null,
        'environment': null,
      }).toDomain();
      expect(c.isUsable, isFalse);
    });

    test('configured:true but a missing id is still not usable', () {
      final c = DojahConfigResponse.fromJson({
        'configured': true,
        'app_id': 'a',
        'public_key': 'k',
      }).toDomain();
      expect(c.isUsable, isFalse);
      expect(DojahConfigResponse.fromJson({}).toDomain().isUsable, isFalse);
    });

    test('start (capture 08)', () {
      final s = StartVerificationResponse.fromJson({
        'reference_id': 'WC-NIN-722d6ac501fca48c',
        'widget_id': 'capture-nin-widget',
        'email': 'artisan@example.com',
        'attempts_remaining': 4,
      }).toDomain();
      expect(s.referenceId, 'WC-NIN-722d6ac501fca48c');
      expect(s.widgetId, 'capture-nin-widget');
      expect(s.email, 'artisan@example.com');
      expect(s.attemptsRemaining, 4);
    });

    test('start without a reference or widget id is rejected', () {
      expect(
        () => StartVerificationResponse.fromJson({'widget_id': 'w'}),
        throwsA(isA<Object>()),
      );
      expect(
        () => StartVerificationResponse.fromJson({'reference_id': 'r'}),
        throwsA(isA<Object>()),
      );
    });
  });

  group('VerificationStatus.fromApi', () {
    test('parses each known value, case-insensitively', () {
      expect(
        VerificationStatus.fromApi('unverified'),
        VerificationStatus.unverified,
      );
      expect(VerificationStatus.fromApi('PENDING'), VerificationStatus.pending);
      expect(
        VerificationStatus.fromApi('verified'),
        VerificationStatus.verified,
      );
      expect(VerificationStatus.fromApi(' failed '), VerificationStatus.failed);
    });

    test('unknown, null and wrong types never throw', () {
      expect(
        VerificationStatus.fromApi('under_review'),
        VerificationStatus.unknown,
      );
      expect(VerificationStatus.fromApi(null), VerificationStatus.unknown);
      expect(VerificationStatus.fromApi(7), VerificationStatus.unknown);
    });
  });

  group('artisan profile verification_status', () {
    Map<String, dynamic> profile(Map<String, dynamic> extra) => {
      'id': 'artisan-1',
      'full_name': 'Test Artisan',
      'availability_status': 'available',
      ...extra,
    };

    test('absent field parses to unknown / not verified', () {
      final p = ArtisanProfileResponseModel.fromJson(profile({})).toDomain();
      expect(p.verificationStatus, VerificationStatus.unknown);
      expect(p.isVerified, isFalse);
      expect(p.effectiveVerificationStatus, VerificationStatus.unknown);
    });

    test('known and unknown values', () {
      expect(
        ArtisanProfileResponseModel.fromJson(
          profile({'verification_status': 'pending'}),
        ).toDomain().verificationStatus,
        VerificationStatus.pending,
      );
      expect(
        ArtisanProfileResponseModel.fromJson(
          profile({'verification_status': 'brand_new'}),
        ).toDomain().verificationStatus,
        VerificationStatus.unknown,
      );
    });

    test('is_verified makes the effective status verified', () {
      final p = ArtisanProfileResponseModel.fromJson(
        profile({'is_verified': true}),
      ).toDomain();
      expect(p.effectiveVerificationStatus, VerificationStatus.verified);
    });
  });
}
