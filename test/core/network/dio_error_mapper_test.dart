import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/core/network/dio_error_mapper.dart';

DioException _bad(int status, Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  group('mapDioError', () {
    test('string detail becomes ApiException with status', () {
      final e = mapDioError(
        _bad(400, {'detail': 'Dispute window has elapsed'}),
      );
      expect(e, isA<ApiException>());
      expect((e as ApiException).message, 'Dispute window has elapsed');
      expect(e.statusCode, 400);
      expect(e.code, isNull);
    });

    test('object detail exposes code and message', () {
      final e =
          mapDioError(
                _bad(422, {
                  'detail': {'code': 'nin_invalid', 'message': 'Bad NIN'},
                }),
              )
              as ApiException;
      expect(e.message, 'Bad NIN');
      expect(e.code, 'nin_invalid');
    });

    test('validation list uses the first msg', () {
      final e =
          mapDioError(
                _bad(422, {
                  'detail': [
                    {
                      'loc': ['body', 'dispute_reason'],
                      'msg': 'too short',
                    },
                  ],
                }),
              )
              as ApiException;
      expect(e.message, 'too short');
    });

    test('unknown body falls back to the provided message', () {
      final e =
          mapDioError(_bad(500, '<html>'), fallbackMessage: 'Try later')
              as ApiException;
      expect(e.message, 'Try later');
      expect(e.statusCode, 500);
    });

    test('401 and timeouts map to typed exceptions', () {
      expect(mapDioError(_bad(401, null)), isA<UnauthorizedException>());
      final timeout = DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: RequestOptions(path: '/x'),
      );
      expect(mapDioError(timeout), isA<NetworkException>());
    });

    test('an interceptor-provided UnauthorizedException is preserved', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        error: UnauthorizedException('Session expired'),
      );
      final mapped = mapDioError(err);
      expect(mapped, isA<UnauthorizedException>());
      expect((mapped as UnauthorizedException).message, 'Session expired');
    });
  });

  group('userMessage', () {
    test('never leaks DioException text', () {
      final text = userMessage(_bad(404, null), fallback: 'Nope');
      expect(text, 'Nope');
      expect(text.contains('DioException'), isFalse);
    });

    test('keeps short Exception messages and hides technical ones', () {
      expect(userMessage(Exception('Out of stock')), 'Out of stock');
      expect(
        userMessage(const FormatException('bad json'), fallback: 'fb'),
        'fb',
      );
      expect(userMessage(StateError('x'), fallback: 'fb'), 'fb');
    });
  });

  test('isOfflineError is true only for connectivity failures', () {
    expect(isOfflineError(NetworkException()), isTrue);
    expect(isOfflineError(_bad(500, null)), isFalse);
    expect(isOfflineError(ApiException('x')), isFalse);
  });
}
