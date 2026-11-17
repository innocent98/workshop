import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/auth/data/datasources/auth_remote_datasource.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  FakeHttpAdapter? adapter;

  AuthRemoteDataSource sourceFor(FakeHandler handler) =>
      AuthRemoteDataSource(dio: fakeDio(handler, adapter: (a) => adapter = a));

  test(
    '204 with no body succeeds and sends DELETE /auth/me with no body',
    () async {
      final source = sourceFor((o) async => ResponseBody.fromString('', 204));

      await source.deleteAccount();

      final request = adapter!.requests.single;
      expect(request.method, 'DELETE');
      expect(request.path, '/auth/me');
      expect(request.data, isNull);
    },
  );

  test('200 with a JSON body also counts as success', () async {
    final source = sourceFor(
      (o) async => jsonResponse({'message': 'Account deleted'}),
    );

    await source.deleteAccount();

    expect(adapter!.requests, hasLength(1));
  });

  for (final status in [404, 405, 501]) {
    test('$status maps to the friendly "not available yet" message', () async {
      final source = sourceFor(
        (o) async => jsonResponse({'detail': 'Not Found'}, status: status),
      );

      await expectLater(
        source.deleteAccount(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', status)
              .having(
                (e) => e.message,
                'message',
                allOf(
                  contains('not available yet'),
                  contains('contact support'),
                  contains('0704 268 5209'),
                ),
              ),
        ),
      );
    });
  }

  test('401 surfaces as UnauthorizedException', () async {
    final source = sourceFor(
      (o) async => jsonResponse({'detail': 'Not authenticated'}, status: 401),
    );

    await expectLater(
      source.deleteAccount(),
      throwsA(isA<UnauthorizedException>()),
    );
  });

  test('a server refusal keeps the backend message', () async {
    final source = sourceFor(
      (o) async => jsonResponse({
        'detail': 'Resolve your active bookings first',
      }, status: 409),
    );

    await expectLater(
      source.deleteAccount(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Resolve your active bookings first',
        ),
      ),
    );
  });

  test('offline surfaces as NetworkException', () async {
    final source = sourceFor(connectionError);

    await expectLater(source.deleteAccount(), throwsA(isA<NetworkException>()));
  });

  test('sends the password as the JSON body when given', () async {
    final source = sourceFor((o) async => jsonResponse({'message': 'ok'}));

    await source.deleteAccount(password: 'pw-placeholder');

    final request = adapter!.requests.single;
    expect(request.method, 'DELETE');
    expect(request.path, '/auth/me');
    expect(request.data, {'password': 'pw-placeholder'});
  });

  test(
    'sends the Google token as google_token for Google-only accounts',
    () async {
      final source = sourceFor((o) async => jsonResponse({'message': 'ok'}));

      await source.deleteAccount(googleToken: 'firebase-token-placeholder');

      expect(adapter!.requests.single.data, {
        'google_token': 'firebase-token-placeholder',
      });
    },
  );

  test('an empty password is not sent', () async {
    final source = sourceFor((o) async => jsonResponse({'message': 'ok'}));

    await source.deleteAccount(password: '');

    expect(adapter!.requests.single.data, isNull);
  });

  // Exact bodies captured from the backend (DELETE /auth/me).
  final structured = <(int, String, String)>[
    (400, 'password_required', 'Enter your password to delete your account.'),
    (
      400,
      'reauth_required',
      'Sign in with Google again to delete your account.',
    ),
    (403, 'invalid_password', 'The password is incorrect.'),
    (
      429,
      'too_many_attempts',
      'Too many incorrect attempts. Please try again in a few minutes.',
    ),
    (
      409,
      'active_bookings',
      'Your account cannot be deleted yet: Finish or cancel your accepted, paid, in-progress and disputed bookings.',
    ),
  ];
  for (final (status, code, message) in structured) {
    test('$status $code keeps the backend message and code', () async {
      final source = sourceFor(
        (o) async => jsonResponse({
          'detail': {'code': code, 'message': message},
        }, status: status),
      );

      await expectLater(
        source.deleteAccount(password: 'pw-placeholder'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', message)
              .having((e) => e.code, 'code', code)
              .having((e) => e.statusCode, 'statusCode', status),
        ),
      );
    });
  }
}
