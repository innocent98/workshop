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
}
