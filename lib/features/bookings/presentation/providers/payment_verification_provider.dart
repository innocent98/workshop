import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/pending_payment_store.dart';
import '../../domain/payment_verification.dart';
import 'artisan_bookings_provider.dart';

class PaymentVerificationState {
  /// Pending payments keyed by booking id.
  final Map<int, PendingPayment> pending;

  /// Booking id of the most recent payment confirmed by the backend, and a
  /// counter so listeners can react once per confirmation.
  final int? lastConfirmedBookingId;
  final int confirmedCount;

  /// Set when the backend says the reference is not ours / does not exist, or
  /// the user's session expired, so the UI can explain why a banner vanished.
  final String? notice;

  const PaymentVerificationState({
    this.pending = const {},
    this.lastConfirmedBookingId,
    this.confirmedCount = 0,
    this.notice,
  });

  bool get hasPending => pending.isNotEmpty;

  PaymentVerificationState copyWith({
    Map<int, PendingPayment>? pending,
    int? lastConfirmedBookingId,
    int? confirmedCount,
    String? notice,
    bool clearNotice = false,
  }) {
    return PaymentVerificationState(
      pending: pending ?? this.pending,
      lastConfirmedBookingId:
          lastConfirmedBookingId ?? this.lastConfirmedBookingId,
      confirmedCount: confirmedCount ?? this.confirmedCount,
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}

final pendingPaymentStoreProvider = Provider<PendingPaymentStore>(
  (ref) => PendingPaymentStore(),
);

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>(
  (ref) => PaymentRemoteDataSource(),
);

/// Retry policy; overridable in tests so waits are instant.
final paymentVerifierProvider = Provider<PaymentVerifier>((ref) {
  final dataSource = ref.watch(paymentRemoteDataSourceProvider);
  return PaymentVerifier(
    verify: (reference) async {
      final result = await dataSource.verifyPayment(
        paymentReference: reference,
      );
      return PaymentVerifyResponse(
        paid: result.paid,
        status: result.status,
        message: result.message,
      );
    },
  );
});

final paymentVerificationProvider =
    NotifierProvider<PaymentVerificationController, PaymentVerificationState>(
      PaymentVerificationController.new,
    );

/// Tracks payments that were handed to Paystack's hosted page and confirms
/// them with the backend once the user is back in the app.
///
/// Success is never assumed: a payment leaves the pending set only after the
/// backend answered `paid: true` (or the reference is invalid/expired).
class PaymentVerificationController extends Notifier<PaymentVerificationState>
    with WidgetsBindingObserver {
  final Set<int> _running = <int>{};
  bool _attached = false;

  @override
  PaymentVerificationState build() {
    ref.onDispose(detach);
    return const PaymentVerificationState();
  }

  /// Starts observing app lifecycle and restores persisted payments from a
  /// previous session. Idempotent; call once the user is signed in.
  Future<void> attach() async {
    if (!_attached) {
      _attached = true;
      WidgetsBinding.instance.addObserver(this);
    }
    await restore();
  }

  void detach() {
    if (_attached) {
      _attached = false;
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && this.state.hasPending) {
      unawaited(verifyAll());
    }
  }

  /// Loads payments saved by a previous run and verifies them.
  Future<void> restore() async {
    final stored = await ref.read(pendingPaymentStoreProvider).load();
    if (stored.isEmpty) return;
    final merged = {...state.pending};
    for (final item in stored) {
      merged.putIfAbsent(
        item.bookingId,
        () => PendingPayment(
          bookingId: item.bookingId,
          reference: item.reference,
          startedAt: item.startedAt,
        ),
      );
    }
    state = state.copyWith(pending: merged);
    await verifyAll();
  }

  /// Registers a payment whose checkout has just been opened.
  Future<void> track({
    required int bookingId,
    required String reference,
  }) async {
    final now = DateTime.now();
    await ref
        .read(pendingPaymentStoreProvider)
        .put(
          StoredPendingPayment(
            bookingId: bookingId,
            reference: reference,
            startedAt: now,
          ),
        );
    state = state.copyWith(
      pending: {
        ...state.pending,
        bookingId: PendingPayment(
          bookingId: bookingId,
          reference: reference,
          startedAt: now,
        ),
      },
      clearNotice: true,
    );
  }

  /// Verifies every pending payment (app resumed / manual "check again").
  Future<void> verifyAll() async {
    final ids = state.pending.keys.toList();
    await Future.wait(ids.map(verify));
  }

  /// Verifies one booking's payment with bounded retries.
  Future<void> verify(int bookingId) async {
    final payment = state.pending[bookingId];
    if (payment == null || !_running.add(bookingId)) return;

    try {
      final verifier = ref.read(paymentVerifierProvider);
      final outcome = await verifier.run(
        payment.reference,
        onAttempt: (attempt, total) => _update(
          bookingId,
          (p) => p.copyWith(
            phase: PendingPaymentPhase.verifying,
            attempt: attempt,
            totalAttempts: total,
          ),
        ),
        isCancelled: () => !state.pending.containsKey(bookingId),
      );

      switch (outcome) {
        case PaymentCheckOutcome.confirmed:
          await _finish(bookingId);
          state = state.copyWith(
            lastConfirmedBookingId: bookingId,
            confirmedCount: state.confirmedCount + 1,
          );
          // Refresh from the server so the card moves to "paid".
          await ref.read(artisanBookingsProvider.notifier).refresh();
        case PaymentCheckOutcome.invalid:
          await _finish(bookingId);
          state = state.copyWith(
            notice:
                'We could not find that payment. If money left your account, contact support.',
          );
        case PaymentCheckOutcome.unauthorized:
          // Keep it stored; the next signed-in session will pick it up.
          _update(
            bookingId,
            (p) => p.copyWith(phase: PendingPaymentPhase.unconfirmed),
          );
        case PaymentCheckOutcome.notConfirmed:
          _update(
            bookingId,
            (p) => p.copyWith(phase: PendingPaymentPhase.unconfirmed),
          );
      }
    } finally {
      _running.remove(bookingId);
    }
  }

  /// The user says they did not pay (or no longer cares): stop tracking.
  Future<void> dismiss(int bookingId) => _finish(bookingId);

  /// Clears everything in memory (called on logout).
  void reset() {
    _running.clear();
    state = const PaymentVerificationState();
  }

  void clearNotice() => state = state.copyWith(clearNotice: true);

  Future<void> _finish(int bookingId) async {
    final next = {...state.pending}..remove(bookingId);
    state = state.copyWith(pending: next);
    await ref.read(pendingPaymentStoreProvider).remove(bookingId);
  }

  void _update(int bookingId, PendingPayment Function(PendingPayment) change) {
    final current = state.pending[bookingId];
    if (current == null) return;
    state = state.copyWith(
      pending: {...state.pending, bookingId: change(current)},
    );
  }
}
