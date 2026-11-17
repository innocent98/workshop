import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/verification/data/datasources/verification_remote_datasource.dart';
import 'package:workchop/features/verification/domain/models/verification_api_exception.dart';
import 'package:workchop/features/verification/domain/models/verification_status.dart';

/// Scripted adapter: no sockets, no platform channels.
class FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

// Bodies below are copied from the backend's live captures
// (docs/fe-captures/verification-admin). Dojah was stubbed at the HTTP layer
// there, so these shapes are verified against the app but not the real Dojah.

const captureConfig = {
  'configured': true,
  'app_id': 'capture-app-id',
  'public_key': 'capture-public-key',
  'widget_id': 'capture-nin-widget',
  'environment': 'sandbox',
};

const captureStart = {
  'reference_id': 'WC-NIN-722d6ac501fca48c',
  'widget_id': 'capture-nin-widget',
  'email': 'artisan@example.com',
  'attempts_remaining': 4,
};

const captureStatusInitial = {
  'verification_status': 'unverified',
  'is_verified': false,
  'verified_at': null,
  'verification_method': null,
  'failure_reason': null,
  'nin_last4': null,
  'reference_id': null,
  'attempts_used': 0,
  'attempts_remaining': 5,
  'max_attempts': 5,
  'window_hours': 24,
  'retry_available_at': null,
};

const captureStatusPending = {
  'verification_status': 'pending',
  'is_verified': false,
  'verified_at': null,
  'verification_method': null,
  'failure_reason': null,
  'nin_last4': null,
  'reference_id': 'WC-NIN-722d6ac501fca48c',
  'attempts_used': 1,
  'attempts_remaining': 4,
  'max_attempts': 5,
  'window_hours': 24,
  'retry_available_at': null,
};

const captureConfirmSelfieFailed = {
  'verification_status': 'failed',
  'is_verified': false,
  'verified_at': null,
  'verification_method': null,
  'failure_reason':
      'Your selfie did not match the photo on record for this NIN. Retake it '
      'in good light, facing the camera, with no hat or glasses.',
  'nin_last4': null,
  'reference_id': 'WC-NIN-722d6ac501fca48c',
  'attempts_used': 1,
  'attempts_remaining': 4,
  'max_attempts': 5,
  'window_hours': 24,
  'retry_available_at': null,
};

const captureConfirmSuccess = {
  'verification_status': 'verified',
  'is_verified': true,
  'verified_at': '2026-11-17T12:58:09.208622Z',
  'verification_method': 'dojah',
  'failure_reason': null,
  'nin_last4': '1117',
  'reference_id': 'WC-NIN-795e18bb751cece1',
  'attempts_used': 3,
  'attempts_remaining': 2,
  'max_attempts': 5,
  'window_hours': 24,
  'retry_available_at': null,
};

const captureStartAlreadyVerified = {
  'detail': {
    'code': 'already_verified',
    'message': 'Your account is already verified.',
  },
};

const captureStartExhausted = {
  'detail': {
    'code': 'attempts_exhausted',
    'message': 'Too many verification attempts. Please try again later.',
    'retry_available_at': '2026-11-18T12:58:11.538849+00:00',
  },
};

const captureConfirmUnknownReference = {
  'detail': {
    'code': 'unknown_reference',
    'message': 'No verification found for that reference',
  },
};

const captureConfirmProviderError = {
  'detail': {
    'code': 'provider_error',
    'message':
        'Could not reach the verification provider. Please try again shortly.',
  },
};

const captureClientForbidden = {
  'detail': 'Only artisans can access this endpoint',
};

void main() {
  VerificationRemoteDataSource build(FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    return VerificationRemoteDataSource(dio: dio);
  }

  DioException transportError(RequestOptions o, DioExceptionType type) =>
      DioException(requestOptions: o, type: type);

  group('paths', () {
    test('there is no bare /verification path any more', () {
      expect(
        VerificationRemoteDataSource.configPath,
        '/profiles/artisans/me/verification/config',
      );
      expect(
        VerificationRemoteDataSource.startPath,
        '/profiles/artisans/me/verification/start',
      );
      expect(
        VerificationRemoteDataSource.confirmPath,
        '/profiles/artisans/me/verification/confirm',
      );
      expect(
        VerificationRemoteDataSource.statusPath,
        '/profiles/artisans/me/verification/status',
      );
    });
  });

  group('getConfig', () {
    test('GETs and parses the config', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureConfig, 200));
      final config = (await build(adapter).getConfig()).toDomain();
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/profiles/artisans/me/verification/config');
      expect(config.isUsable, isTrue);
      expect(config.appId, 'capture-app-id');
    });

    test('client account gets the string-detail 403', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureClientForbidden, 403));
      await expectLater(
        build(adapter).getConfig(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.code, 'code', isNull)
              .having(
                (e) => e.message,
                'message',
                'Only artisans can access this endpoint',
              ),
        ),
      );
    });
  });

  group('start', () {
    test('POSTs with no body and parses the reference', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureStart, 200));
      final result = (await build(adapter).start()).toDomain();
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/profiles/artisans/me/verification/start');
      expect(request.data, isNull);
      expect(result.referenceId, 'WC-NIN-722d6ac501fca48c');
      expect(result.attemptsRemaining, 4);
    });

    test('409 already_verified', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(captureStartAlreadyVerified, 409),
      );
      await expectLater(
        build(adapter).start(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'already_verified')
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('429 attempts_exhausted exposes retry_available_at', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureStartExhausted, 429));
      await expectLater(
        build(adapter).start(),
        throwsA(
          isA<VerificationApiException>()
              .having((e) => e.code, 'code', 'attempts_exhausted')
              .having((e) => e.statusCode, 'statusCode', 429)
              .having(
                (e) => e.retryAvailableAt,
                'retryAvailableAt',
                DateTime.utc(2026, 11, 18, 12, 58, 11, 538, 849),
              ),
        ),
      );
    });

    test('503 verification_unavailable', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody({
          'detail': {
            'code': 'verification_unavailable',
            'message': 'Verification is not available right now.',
          },
        }, 503),
      );
      await expectLater(
        build(adapter).start(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'verification_unavailable')
              .having((e) => e.statusCode, 'statusCode', 503),
        ),
      );
    });

    test(
      'is never retried: a failure results in exactly one request',
      () async {
        final adapter = FakeAdapter(
          (o) => throw transportError(o, DioExceptionType.receiveTimeout),
        );
        await expectLater(
          build(adapter).start(),
          throwsA(isA<NetworkException>()),
        );
        expect(adapter.requests, hasLength(1));
      },
    );

    test('a response without a reference is an error', () async {
      final adapter = FakeAdapter((_) => jsonBody({'widget_id': 'w'}, 200));
      await expectLater(build(adapter).start(), throwsA(isA<ApiException>()));
    });
  });

  group('confirm', () {
    test('sends only the reference id as JSON', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureConfirmSuccess, 200));
      final result = (await build(
        adapter,
      ).confirm('WC-NIN-795e18bb751cece1')).toDomain();
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/profiles/artisans/me/verification/confirm');
      expect(request.data, {'reference_id': 'WC-NIN-795e18bb751cece1'});
      expect(result.status, VerificationStatus.verified);
      expect(result.ninLast4, '1117');
      expect(result.method, 'dojah');
    });

    test('200 failed carries the reason verbatim', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(captureConfirmSelfieFailed, 200),
      );
      final result = (await build(
        adapter,
      ).confirm('WC-NIN-722d6ac501fca48c')).toDomain();
      expect(result.status, VerificationStatus.failed);
      expect(
        result.failureReason,
        captureConfirmSelfieFailed['failure_reason'],
      );
      expect(result.attemptsRemaining, 4);
    });

    test('404 unknown_reference', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(captureConfirmUnknownReference, 404),
      );
      await expectLater(
        build(adapter).confirm('WC-NIN-doesnotexist'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'unknown_reference')
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('502 provider_error', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(captureConfirmProviderError, 502),
      );
      await expectLater(
        build(adapter).confirm('WC-NIN-795e18bb751cece1'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'provider_error')
              .having((e) => e.statusCode, 'statusCode', 502),
        ),
      );
    });

    test('422 validation list is parsed without crashing', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody({
          'detail': [
            {
              'type': 'missing',
              'loc': ['body', 'reference_id'],
              'msg': 'Field required',
            },
          ],
        }, 422),
      );
      await expectLater(
        build(adapter).confirm(''),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.code, 'code', isNull),
        ),
      );
    });

    test('timeout and offline become NetworkException', () async {
      for (final type in [
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        final adapter = FakeAdapter((o) => throw transportError(o, type));
        await expectLater(
          build(adapter).confirm('WC-NIN-x'),
          throwsA(isA<NetworkException>()),
        );
      }
    });
  });

  group('getStatus', () {
    test('GETs /status and parses unverified', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureStatusInitial, 200));
      final status = (await build(adapter).getStatus()).toDomain();
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/profiles/artisans/me/verification/status');
      expect(status.status, VerificationStatus.unverified);
      expect(status.referenceId, isNull);
      expect(status.attemptsRemaining, 5);
    });

    test('parses pending with its reference', () async {
      final adapter = FakeAdapter((_) => jsonBody(captureStatusPending, 200));
      final status = (await build(adapter).getStatus()).toDomain();
      expect(status.status, VerificationStatus.pending);
      expect(status.referenceId, 'WC-NIN-722d6ac501fca48c');
      expect(status.attemptsUsed, 1);
    });

    test('offline becomes NetworkException', () async {
      final adapter = FakeAdapter(
        (o) => throw transportError(o, DioExceptionType.connectionError),
      );
      await expectLater(
        build(adapter).getStatus(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
