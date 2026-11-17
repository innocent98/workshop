import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/core/network/auth_interceptor.dart';
import 'package:workchop/core/network/dio_error_mapper.dart';
import 'package:workchop/core/services/token_storage_service.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Dio dioWith(FakeHandler handler) {
    final dio = fakeDio(handler);
    dio.interceptors.add(AuthInterceptor());
    return dio;
  }

  setUp(() => FlutterSecureStorage.setMockInitialValues({'auth_token': 'tok'}));

  // The account-deletion errors carry `detail` as an object, not a string. The
  // interceptor used to cast `detail` to String and throw, so the real reason
  // (wrong password, blocked by a booking, too many attempts) never reached the
  // user.
  for (final (status, code, message) in [
    (403, 'invalid_password', 'The password is incorrect.'),
    (409, 'active_bookings', 'Your account cannot be deleted yet: Finish.'),
    (429, 'too_many_attempts', 'Too many incorrect attempts.'),
  ]) {
    test('$status with an object detail keeps code and message', () async {
      final dio = dioWith(
        (o) async => jsonResponse({
          'detail': {'code': code, 'message': message},
        }, status: status),
      );

      final error = await dio
          .delete('/auth/me')
          .then<DioException?>((_) => null)
          .catchError((Object e) => e as DioException);

      expect(error, isNotNull);
      final mapped = mapDioError(error!);
      expect(mapped, isA<ApiException>());
      expect((mapped as ApiException).message, message);
      expect(mapped.code, code);
      expect(
        await TokenStorageService().hasToken(),
        isTrue,
        reason: 'a refused deletion must not end the session',
      );
    });
  }

  test('401 on login surfaces the message without a forced logout', () async {
    final dio = dioWith(
      (o) async =>
          jsonResponse({'detail': 'Invalid email or password'}, status: 401),
    );

    final error = await dio
        .post('/auth/login')
        .then<DioException?>((_) => null)
        .catchError((Object e) => e as DioException);

    expect(error!.error, isA<UnauthorizedException>());
    expect(
      (error.error! as UnauthorizedException).message,
      'Invalid email or password',
    );
    expect(await TokenStorageService().hasToken(), isTrue);
  });
}
