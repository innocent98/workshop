import 'dart:convert';
import 'dart:io';
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

// Shape copied from the contract draft. Placeholder values only.
Map<String, dynamic> statusBody(String s, {Map<String, dynamic>? extra}) => {
  'verification_status': s,
  'is_verified': s == 'verified',
  'verified_at': null,
  'verification_method': null,
  'failure_reason': null,
  'nin_last4': null,
  'attempts_used': 0,
  'attempts_remaining': 5,
  'max_attempts': 5,
  'window_hours': 24,
  'retry_available_at': null,
  ...?extra,
};

void main() {
  late Directory tmp;
  late File selfie;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('verification_test');
    selfie = File('${tmp.path}/selfie.jpg')
      ..writeAsBytesSync(List<int>.filled(16, 7));
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  VerificationRemoteDataSource build(FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    return VerificationRemoteDataSource(dio: dio);
  }

  group('getVerification', () {
    test('GETs the status endpoint and parses it', () async {
      final adapter = FakeAdapter((_) => jsonBody(statusBody('pending'), 200));
      final result = await build(adapter).getVerification();

      expect(adapter.requests.single.method, 'GET');
      expect(
        adapter.requests.single.path,
        '/profiles/artisans/me/verification',
      );
      expect(result.toDomain().status, VerificationStatus.pending);
    });

    test('connection failure becomes NetworkException', () async {
      final adapter = FakeAdapter(
        (o) => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        build(adapter).getVerification(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('timeout becomes NetworkException', () async {
      final adapter = FakeAdapter(
        (o) => throw DioException(
          requestOptions: o,
          type: DioExceptionType.receiveTimeout,
        ),
      );
      await expectLater(
        build(adapter).getVerification(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('403 string detail becomes ApiException with status', () async {
      final adapter = FakeAdapter(
        (_) =>
            jsonBody({'detail': 'Only artisans can access this endpoint'}, 403),
      );
      await expectLater(
        build(adapter).getVerification(),
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

  group('submitVerification', () {
    test('sends multipart nin + selfie with a 45s timeout', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(
          statusBody(
            'verified',
            extra: {'verification_method': 'dojah', 'nin_last4': '0000'},
          ),
          200,
        ),
      );
      final result = await build(
        adapter,
      ).submitVerification(nin: '00000000000', selfie: selfie);

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/profiles/artisans/me/verification');
      expect(request.sendTimeout, const Duration(seconds: 45));
      expect(request.receiveTimeout, const Duration(seconds: 45));

      final form = request.data as FormData;
      expect(form.fields.length, 1);
      expect(form.fields.single.key, 'nin');
      expect(form.fields.single.value, '00000000000');
      expect(form.files.single.key, 'selfie');
      expect(form.files.single.value.filename, 'selfie.jpg');
      expect(form.files.single.value.contentType.toString(), 'image/jpeg');

      expect(result.toDomain().status, VerificationStatus.verified);
      expect(result.verificationMethod, 'dojah');
    });

    test('a failed match is a normal 200, not an exception', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(
          statusBody(
            'failed',
            extra: {
              'failure_reason': 'Selfie did not match',
              'attempts_used': 1,
              'attempts_remaining': 4,
            },
          ),
          200,
        ),
      );
      final result = await build(
        adapter,
      ).submitVerification(nin: '00000000000', selfie: selfie);
      final domain = result.toDomain();
      expect(domain.status, VerificationStatus.failed);
      expect(domain.failureReason, 'Selfie did not match');
      expect(domain.attemptsRemaining, 4);
    });

    // Every error row of the contract: {detail: {code, message}}.
    const errors = <(int, String)>[
      (400, 'invalid_nin'),
      (400, 'invalid_image'),
      (413, 'invalid_image'),
      (409, 'already_verified'),
      (409, 'verification_in_progress'),
      (503, 'verification_unavailable'),
    ];
    for (final (httpStatus, code) in errors) {
      test('$httpStatus $code carries code and status', () async {
        final adapter = FakeAdapter(
          (_) => jsonBody({
            'detail': {'code': code, 'message': 'backend message'},
          }, httpStatus),
        );
        await expectLater(
          build(adapter).submitVerification(nin: '00000000000', selfie: selfie),
          throwsA(
            isA<ApiException>()
                .having((e) => e.code, 'code', code)
                .having((e) => e.statusCode, 'statusCode', httpStatus)
                .having((e) => e.message, 'message', 'backend message'),
          ),
        );
      });
    }

    test('429 attempts_exhausted exposes retry_available_at', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody({
          'detail': {
            'code': 'attempts_exhausted',
            'message': 'Too many attempts',
            'retry_available_at': '2026-11-18T09:30:00Z',
          },
        }, 429),
      );
      await expectLater(
        build(adapter).submitVerification(nin: '00000000000', selfie: selfie),
        throwsA(
          isA<VerificationApiException>()
              .having((e) => e.code, 'code', 'attempts_exhausted')
              .having((e) => e.statusCode, 'statusCode', 429)
              .having(
                (e) => e.retryAvailableAt,
                'retryAvailableAt',
                DateTime.utc(2026, 11, 18, 9, 30),
              ),
        ),
      );
    });

    test('422 validation list is parsed without crashing', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody({
          'detail': [
            {
              'type': 'missing',
              'loc': ['body', 'nin'],
              'msg': 'Field required',
            },
          ],
        }, 422),
      );
      await expectLater(
        build(adapter).submitVerification(nin: '00000000000', selfie: selfie),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.code, 'code', isNull),
        ),
      );
    });

    test('timeout becomes NetworkException', () async {
      final adapter = FakeAdapter(
        (o) => throw DioException(
          requestOptions: o,
          type: DioExceptionType.receiveTimeout,
        ),
      );
      await expectLater(
        build(adapter).submitVerification(nin: '00000000000', selfie: selfie),
        throwsA(isA<NetworkException>()),
      );
    });

    test('does not delete or modify the file it was given', () async {
      final adapter = FakeAdapter((_) => jsonBody(statusBody('pending'), 200));
      await build(
        adapter,
      ).submitVerification(nin: '00000000000', selfie: selfie);
      // Cleanup is the caller's job (the provider deletes its temp copy).
      expect(selfie.existsSync(), isTrue);
    });
  });
}
