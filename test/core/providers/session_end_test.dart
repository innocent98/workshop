import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workchop/core/models/user.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/core/providers/auth_provider.dart';
import 'package:workchop/core/providers/registration_provider.dart';
import 'package:workchop/core/providers/service_guard_provider.dart';
import 'package:workchop/core/providers/session_reset.dart';
import 'package:workchop/core/services/push_token_gateway.dart';
import 'package:workchop/core/services/token_storage_service.dart';
import 'package:workchop/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:workchop/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:workchop/features/auth/domain/repositories/auth_repository.dart';
import 'package:workchop/features/bookings/data/datasources/artisan_bookings_remote_datasource.dart';
import 'package:workchop/features/bookings/data/pending_payment_store.dart';
import 'package:workchop/features/bookings/data/repositories/artisan_bookings_repository_impl.dart';
import 'package:workchop/features/bookings/presentation/providers/artisan_bookings_provider.dart';
import 'package:workchop/features/bookings/presentation/providers/payment_verification_provider.dart';

import '../../helpers/booking_fixtures.dart';
import '../../helpers/fake_http_adapter.dart';

const _user = User(
  id: 'user-1',
  fullName: 'Test User',
  email: 'test@example.invalid',
  phoneNumber: '+2340000000000',
  role: UserRole.client,
  userType: 'client',
);

/// Real repository over a scripted adapter, so what is asserted is the actual
/// `/auth/logout` and `DELETE /auth/me` wire behaviour.
class _Backend {
  _Backend({this.logoutStatus = 200, this.logoutOffline = false});

  int logoutStatus;
  bool logoutOffline;
  int deleteStatus = 204;
  final List<String> calls = [];

  AuthRepository get repository => AuthRepositoryImpl(
    AuthRemoteDataSource(
      dio: fakeDio((o) async {
        calls.add('${o.method} ${o.path}');
        if (o.path == '/auth/logout') {
          if (logoutOffline) return connectionError(o);
          return jsonResponse({'message': 'ok'}, status: logoutStatus);
        }
        if (o.path == '/auth/me') {
          return deleteStatus == 204
              ? ResponseBody.fromString('', 204)
              : jsonResponse({'detail': 'nope'}, status: deleteStatus);
        }
        return jsonResponse({}, status: 404);
      }),
    ),
  );
}

class _FakePush implements PushTokenGateway {
  _FakePush({this.unregisterThrows = false});
  final bool unregisterThrows;
  int unregisterCalls = 0;

  @override
  Future<void> sync() async {}

  @override
  Future<void> unregister() async {
    unregisterCalls++;
    if (unregisterThrows) {
      // What FirebaseMessaging.getToken does on the iOS simulator.
      throw Exception('[firebase_messaging/apns-token-not-set]');
    }
  }
}

Future<void> _seedSignedInDevice() async {
  SharedPreferences.setMockInitialValues({
    'user_data': jsonEncode(_user.toJson()),
    'pending_payments_v1': jsonEncode([
      StoredPendingPayment(
        bookingId: 9,
        reference: 'REF',
        startedAt: DateTime.now(),
      ).toJson(),
    ]),
  });
  FlutterSecureStorage.setMockInitialValues({'auth_token': 'tok'});
}

ProviderContainer _container({
  required _Backend backend,
  required PushTokenGateway push,
  List<Override> extra = const [],
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      authRepositoryProvider.overrideWithValue(backend.repository),
      pushTokenGatewayProvider.overrideWithValue(push),
      sessionResetDelayProvider.overrideWithValue(Duration.zero),
      ...extra,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _expectDeviceCleared() async {
  expect(await TokenStorageService().hasToken(), isFalse);
  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getString('user_data'), isNull);
  expect(await PendingPaymentStore().load(), isEmpty);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('logout', () {
    test('clears the whole session and ends signed out', () async {
      await _seedSignedInDevice();
      final backend = _Backend();
      final container = _container(backend: backend, push: _FakePush());
      expect(await container.read(authProvider.future), isNotNull);
      container
          .read(serviceGuardProvider.notifier)
          .setForUser(userId: 'user-1', hasServices: true);

      await container.read(authProvider.notifier).logout();

      expect(backend.calls, ['POST /auth/logout']);
      expect(container.read(authProvider).requireValue, isNull);
      expect(container.read(serviceGuardProvider).hasCheckedThisSession, false);
      await _expectDeviceCleared();
    });

    test('regression: a throwing push unregister (iOS simulator) no longer '
        'leaves the token behind or the auth state in error', () async {
      await _seedSignedInDevice();
      final push = _FakePush(unregisterThrows: true);
      final container = _container(backend: _Backend(), push: push);
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).logout();

      expect(push.unregisterCalls, 1);
      final state = container.read(authProvider);
      expect(
        state.hasError,
        isFalse,
        reason: 'must never show "Failed to load user"',
      );
      expect(state.requireValue, isNull);
      await _expectDeviceCleared();
    });

    test(
      'still logs out when the backend is offline or rejects the call',
      () async {
        for (final backend in [
          _Backend(logoutOffline: true),
          _Backend(logoutStatus: 500),
          _Backend(logoutStatus: 401),
        ]) {
          await _seedSignedInDevice();
          final container = _container(backend: backend, push: _FakePush());
          await container.read(authProvider.future);

          await container.read(authProvider.notifier).logout();

          expect(container.read(authProvider).requireValue, isNull);
          await _expectDeviceCleared();
        }
      },
    );

    test(
      'never passes through a loading state the UI could trap itself in',
      () async {
        await _seedSignedInDevice();
        final container = _container(backend: _Backend(), push: _FakePush());
        await container.read(authProvider.future);
        final seen = <AsyncValue<User?>>[];
        container.listen(authProvider, (_, next) => seen.add(next));

        await container.read(authProvider.notifier).logout();

        expect(seen, hasLength(1));
        expect(seen.single.value, isNull);
        expect(seen.single.isLoading, isFalse);
      },
    );
  });

  group('forced logout (401)', () {
    test('uses the same cleanup without calling the backend', () async {
      await _seedSignedInDevice();
      final backend = _Backend();
      final push = _FakePush();
      final container = _container(backend: backend, push: push);
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).endSessionLocally();

      expect(backend.calls, isEmpty);
      expect(push.unregisterCalls, 0);
      expect(container.read(authProvider).requireValue, isNull);
      await _expectDeviceCleared();
    });
  });

  group('deleteAccount', () {
    test(
      'success sends DELETE /auth/me then runs the logout cleanup',
      () async {
        await _seedSignedInDevice();
        final backend = _Backend();
        final container = _container(backend: backend, push: _FakePush());
        await container.read(authProvider.future);

        await container.read(authProvider.notifier).deleteAccount();

        expect(backend.calls, ['DELETE /auth/me']);
        expect(container.read(authProvider).requireValue, isNull);
        await _expectDeviceCleared();
      },
    );

    test(
      'failure rethrows and leaves the user signed in with data intact',
      () async {
        await _seedSignedInDevice();
        final backend = _Backend()..deleteStatus = 501;
        final container = _container(backend: backend, push: _FakePush());
        await container.read(authProvider.future);

        await expectLater(
          container.read(authProvider.notifier).deleteAccount(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              contains('contact support'),
            ),
          ),
        );

        expect(container.read(authProvider).requireValue, isNotNull);
        expect(await TokenStorageService().hasToken(), isTrue);
        expect(
          (await SharedPreferences.getInstance()).getString('user_data'),
          isNotNull,
        );
        expect(await PendingPaymentStore().load(), hasLength(1));
      },
    );
  });

  group('session reset', () {
    test('after sign-out every account-scoped provider is dropped, '
        'so the next user never sees the previous user\'s data', () async {
      await _seedSignedInDevice();
      var fetches = 0;
      final dio = fakeDio((o) async {
        fetches++;
        return jsonResponse({
          'bookings': [bookingJson(id: fetches)],
          'total': 1,
          'page': 1,
          'page_size': 100,
        });
      });
      final container = _container(
        backend: _Backend(),
        push: _FakePush(),
        extra: [
          artisanBookingsRepositoryProvider.overrideWithValue(
            ArtisanBookingsRepositoryImpl(
              remoteDataSource: ArtisanBookingsRemoteDataSource(dio: dio),
            ),
          ),
        ],
      );
      container.read(sessionResetProvider);
      await container.read(authProvider.future);
      final before = await container.read(artisanBookingsProvider.future);
      container
          .read(paymentVerificationProvider.notifier)
          .track(bookingId: 9, reference: 'REF');
      expect(before.single.id, 1);

      await container.read(authProvider.notifier).logout();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Dropped, not stale: the next read refetches.
      final after = await container.read(artisanBookingsProvider.future);
      expect(fetches, 2);
      expect(after.single.id, 2);
      expect(container.read(paymentVerificationProvider).hasPending, isFalse);
    });

    test(
      'a refresh of the auth user (profile photo change) does not reset anything',
      () async {
        await _seedSignedInDevice();
        var fetches = 0;
        final dio = fakeDio((o) async {
          fetches++;
          return jsonResponse({
            'bookings': <Map<String, dynamic>>[],
            'total': 0,
            'page': 1,
            'page_size': 100,
          });
        });
        final container = _container(
          backend: _Backend(),
          push: _FakePush(),
          extra: [
            artisanBookingsRepositoryProvider.overrideWithValue(
              ArtisanBookingsRepositoryImpl(
                remoteDataSource: ArtisanBookingsRemoteDataSource(dio: dio),
              ),
            ),
          ],
        );
        container.read(sessionResetProvider);
        await container.read(authProvider.future);
        await container.read(artisanBookingsProvider.future);

        container.invalidate(authProvider);
        await container.read(authProvider.future);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await container.read(artisanBookingsProvider.future);
        expect(fetches, 1);
      },
    );
  });
}
