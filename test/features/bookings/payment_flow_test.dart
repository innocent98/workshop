import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/bookings/data/datasources/payment_remote_datasource.dart';
import 'package:workchop/features/bookings/data/pending_payment_store.dart';
import 'package:workchop/features/bookings/domain/models/artisan_booking.dart';
import 'package:workchop/features/bookings/domain/payment_verification.dart';
import 'package:workchop/features/bookings/domain/repositories/artisan_bookings_repository.dart';
import 'package:workchop/features/bookings/presentation/providers/artisan_bookings_provider.dart';
import 'package:workchop/features/bookings/presentation/providers/payment_verification_provider.dart';

import '../../helpers/fake_http_adapter.dart';

class _FakeRepo implements ArtisanBookingsRepository {
  int listCalls = 0;

  @override
  Future<List<ArtisanBooking>> listBookings({String? statusFilter}) async {
    listCalls++;
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

PaymentVerifyResponse _resp({required bool paid, String status = 'success'}) =>
    PaymentVerifyResponse(paid: paid, status: status, message: 'm');

PaymentVerifier _verifier(
  List<Object> script, {
  List<Duration>? delays,
  List<Duration>? waits,
}) {
  var i = 0;
  return PaymentVerifier(
    retryDelays: delays ?? const [Duration(seconds: 2), Duration(seconds: 4)],
    wait: (d) async => waits?.add(d),
    verify: (ref) async {
      final step = script[i < script.length ? i : script.length - 1];
      i++;
      if (step is Exception) throw step;
      return step as PaymentVerifyResponse;
    },
  );
}

void main() {
  group('PaymentVerifier', () {
    test('default budget is 5 tries over ~20 seconds', () {
      final v = PaymentVerifier(verify: (_) async => _resp(paid: false));
      expect(v.maxAttempts, 5);
      final total = v.retryDelays.fold<Duration>(
        Duration.zero,
        (a, b) => a + b,
      );
      expect(total, const Duration(seconds: 20));
    });

    test('stops at the first paid:true', () async {
      final waits = <Duration>[];
      final outcome = await _verifier([
        _resp(paid: false, status: 'failed'),
        _resp(paid: true),
      ], waits: waits).run('REF');
      expect(outcome, PaymentCheckOutcome.confirmed);
      expect(waits, [const Duration(seconds: 2)]);
    });

    test(
      'paid:false for every attempt is not confirmed, never success',
      () async {
        final attempts = <int>[];
        final outcome = await _verifier([
          _resp(paid: false, status: 'failed'),
        ]).run('REF', onAttempt: (a, t) => attempts.add(a));
        expect(outcome, PaymentCheckOutcome.notConfirmed);
        expect(attempts, [1, 2, 3]);
      },
    );

    test('transient errors are retried', () async {
      final outcome = await _verifier([
        NetworkException(),
        ApiException('Payment verification failed: upstream', 500),
        _resp(paid: true),
      ]).run('REF');
      expect(outcome, PaymentCheckOutcome.confirmed);
    });

    test('404/403 are terminal (invalid) and not retried', () async {
      final waits = <Duration>[];
      final outcome = await _verifier([
        ApiException('Payment not found', 404),
      ], waits: waits).run('REF');
      expect(outcome, PaymentCheckOutcome.invalid);
      expect(waits, isEmpty);
    });

    test('401 stops immediately', () async {
      final outcome = await _verifier([UnauthorizedException()]).run('REF');
      expect(outcome, PaymentCheckOutcome.unauthorized);
    });

    test('a malformed response is treated as transient, not success', () async {
      final outcome = await _verifier([
        const FormatException('bad'),
      ]).run('REF');
      expect(outcome, PaymentCheckOutcome.notConfirmed);
    });
  });

  group('PaymentRemoteDataSource (fake Dio)', () {
    test('initialize + verify map the documented payloads', () async {
      final dio = fakeDio((o) async {
        if (o.path == '/payments/initialize') {
          return jsonResponse({
            'payment_reference': 'PAY-TEST-1',
            'authorization_url': 'https://checkout.example/abc',
          });
        }
        return jsonResponse({
          'payment_reference': 'PAY-TEST-1',
          'status': 'success',
          'amount': '7500.00',
          'paid': true,
          'message': 'Payment verified successfully',
        });
      });
      final ds = PaymentRemoteDataSource(dio: dio);

      final init = await ds.initializePayment(bookingId: 42);
      expect(init.paymentReference, 'PAY-TEST-1');
      expect(init.authorizationUrl, 'https://checkout.example/abc');

      final verify = await ds.verifyPayment(paymentReference: 'PAY-TEST-1');
      expect(verify.paid, isTrue);
      expect(verify.status, 'success');
    });

    test('verify: paid false and 404 shapes', () async {
      final unpaid = PaymentRemoteDataSource(
        dio: fakeDio(
          (o) async => jsonResponse({
            'payment_reference': 'P',
            'status': 'failed',
            'amount': '1.00',
            'paid': false,
            'message': 'Payment verification failed',
          }),
        ),
      );
      expect((await unpaid.verifyPayment(paymentReference: 'P')).paid, isFalse);

      final missing = PaymentRemoteDataSource(
        dio: fakeDio(
          (o) async =>
              jsonResponse({'detail': 'Payment not found'}, status: 404),
        ),
      );
      await expectLater(
        missing.verifyPayment(paymentReference: 'P'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
      );
    });
  });

  group('PendingPaymentStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('persists, replaces per booking, and removes', () async {
      final store = PendingPaymentStore();
      final now = DateTime.now();
      await store.put(
        StoredPendingPayment(bookingId: 1, reference: 'A', startedAt: now),
      );
      await store.put(
        StoredPendingPayment(bookingId: 2, reference: 'B', startedAt: now),
      );
      await store.put(
        StoredPendingPayment(bookingId: 1, reference: 'A2', startedAt: now),
      );

      final loaded = await PendingPaymentStore().load(); // fresh instance
      expect(
        {for (final p in loaded) p.bookingId: p.reference},
        {1: 'A2', 2: 'B'},
      );

      await store.remove(1);
      expect((await store.load()).map((p) => p.bookingId), [2]);
      await store.clear();
      expect(await store.load(), isEmpty);
    });

    test('drops expired entries and survives corrupt data', () async {
      final store = PendingPaymentStore(maxAge: const Duration(hours: 1));
      await store.put(
        StoredPendingPayment(
          bookingId: 1,
          reference: 'OLD',
          startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      expect(await store.load(), isEmpty);

      SharedPreferences.setMockInitialValues({
        'pending_payments_v1': '{not json',
      });
      expect(await PendingPaymentStore().load(), isEmpty);
    });
  });

  group('PaymentVerificationController', () {
    late _FakeRepo repo;

    ProviderContainer container(PaymentVerifier verifier) {
      repo = _FakeRepo();
      final c = ProviderContainer(
        overrides: [
          paymentVerifierProvider.overrideWithValue(verifier),
          artisanBookingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'confirmed: leaves pending, clears storage, refreshes bookings',
      () async {
        final c = container(_verifier([_resp(paid: true)]));
        final ctl = c.read(paymentVerificationProvider.notifier);

        await ctl.track(bookingId: 42, reference: 'REF');
        expect(c.read(paymentVerificationProvider).pending.keys, [42]);
        expect(await PendingPaymentStore().load(), hasLength(1));

        await ctl.verify(42);

        final s = c.read(paymentVerificationProvider);
        expect(s.pending, isEmpty);
        expect(s.lastConfirmedBookingId, 42);
        expect(s.confirmedCount, 1);
        expect(await PendingPaymentStore().load(), isEmpty);
        expect(repo.listCalls, greaterThanOrEqualTo(1));
      },
    );

    test(
      'unconfirmed: stays pending and stored, no success signalled',
      () async {
        final c = container(_verifier([_resp(paid: false, status: 'failed')]));
        final ctl = c.read(paymentVerificationProvider.notifier);
        await ctl.track(bookingId: 42, reference: 'REF');

        await ctl.verify(42);

        final s = c.read(paymentVerificationProvider);
        expect(s.pending[42]!.phase, PendingPaymentPhase.unconfirmed);
        expect(s.confirmedCount, 0);
        expect(s.lastConfirmedBookingId, isNull);
        expect(await PendingPaymentStore().load(), hasLength(1));

        // Manual "I've paid, check again" works from the unconfirmed state.
        await ctl.verify(42);
        expect(c.read(paymentVerificationProvider).confirmedCount, 0);
      },
    );

    test('a killed app recovers the pending reference on restore()', () async {
      // Session 1: payment started, app killed before it was confirmed.
      await PendingPaymentStore().put(
        StoredPendingPayment(
          bookingId: 7,
          reference: 'RECOVER-ME',
          startedAt: DateTime.now(),
        ),
      );

      // Session 2: fresh container, nothing in memory.
      final c = container(_verifier([_resp(paid: true)]));
      expect(c.read(paymentVerificationProvider).pending, isEmpty);

      await c.read(paymentVerificationProvider.notifier).restore();

      final s = c.read(paymentVerificationProvider);
      expect(s.confirmedCount, 1);
      expect(s.lastConfirmedBookingId, 7);
      expect(s.pending, isEmpty);
    });

    test('invalid reference is dropped with an explanatory notice', () async {
      final c = container(_verifier([ApiException('Payment not found', 404)]));
      final ctl = c.read(paymentVerificationProvider.notifier);
      await ctl.track(bookingId: 5, reference: 'GONE');

      await ctl.verify(5);

      final s = c.read(paymentVerificationProvider);
      expect(s.pending, isEmpty);
      expect(s.confirmedCount, 0);
      expect(s.notice, isNotNull);
      expect(await PendingPaymentStore().load(), isEmpty);
    });

    test('dismiss stops tracking and clears storage', () async {
      final c = container(_verifier([_resp(paid: false)]));
      final ctl = c.read(paymentVerificationProvider.notifier);
      await ctl.track(bookingId: 5, reference: 'X');
      await ctl.dismiss(5);
      expect(c.read(paymentVerificationProvider).pending, isEmpty);
      expect(await PendingPaymentStore().load(), isEmpty);
    });

    test('concurrent verify calls for one booking run once', () async {
      var calls = 0;
      final verifier = PaymentVerifier(
        retryDelays: const [],
        verify: (ref) async {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return _resp(paid: false);
        },
      );
      final c = container(verifier);
      final ctl = c.read(paymentVerificationProvider.notifier);
      await ctl.track(bookingId: 1, reference: 'X');
      await Future.wait([ctl.verify(1), ctl.verify(1), ctl.verifyAll()]);
      expect(calls, 1);
    });
  });
}
