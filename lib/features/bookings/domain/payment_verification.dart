import '../../../core/network/api_exception.dart';

/// Result of checking one payment reference against the backend.
enum PaymentCheckOutcome {
  /// The backend answered `paid: true`. The only outcome that means success.
  confirmed,

  /// The backend answered but the payment is not (yet) paid, or the check
  /// failed transiently (network, 5xx). Safe to retry later.
  notConfirmed,

  /// The reference is unknown or not ours (404/403). Retrying cannot help.
  invalid,

  /// The session expired (401). Stop and let the login flow take over.
  unauthorized,
}

/// What a single verify call reports; kept independent of the datasource so
/// the retry logic can be unit tested without Dio.
class PaymentVerifyResponse {
  final bool paid;
  final String status;
  final String message;

  const PaymentVerifyResponse({
    required this.paid,
    required this.status,
    required this.message,
  });
}

typedef VerifyCall = Future<PaymentVerifyResponse> Function(String reference);
typedef WaitFn = Future<void> Function(Duration duration);

/// Default backoff between the five attempts: 2s, 4s, 6s, 8s = ~20s total.
const List<Duration> kDefaultPaymentRetryDelays = [
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 6),
  Duration(seconds: 8),
];

/// Verifies a payment with bounded retries.
///
/// The backend's `GET /payments/verify/{reference}` asks Paystack on every
/// call and answers `paid: false` both for "still processing" and for
/// "failed", so `paid: false` is never treated as terminal here: it is retried
/// until the budget is spent, then reported as [PaymentCheckOutcome.notConfirmed].
/// Success is only ever reported when the backend says `paid: true`.
class PaymentVerifier {
  PaymentVerifier({
    required this.verify,
    this.retryDelays = kDefaultPaymentRetryDelays,
    WaitFn? wait,
  }) : _wait = wait ?? ((d) => Future<void>.delayed(d));

  final VerifyCall verify;
  final List<Duration> retryDelays;
  final WaitFn _wait;

  int get maxAttempts => retryDelays.length + 1;

  /// Runs up to [maxAttempts] checks. [onAttempt] is called before each one
  /// with a 1-based attempt number. [isCancelled] is polled between attempts.
  Future<PaymentCheckOutcome> run(
    String reference, {
    void Function(int attempt, int total)? onAttempt,
    bool Function()? isCancelled,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (isCancelled?.call() ?? false) return PaymentCheckOutcome.notConfirmed;
      onAttempt?.call(attempt, maxAttempts);

      try {
        final response = await verify(reference);
        if (response.paid) return PaymentCheckOutcome.confirmed;
      } on UnauthorizedException {
        return PaymentCheckOutcome.unauthorized;
      } on ApiException catch (e) {
        if (e.statusCode == 404 || e.statusCode == 403) {
          return PaymentCheckOutcome.invalid;
        }
        // Other API errors (5xx from Paystack etc.) are transient.
      } on NetworkException {
        // Offline or timeout: retry.
      } on Exception {
        // Malformed response etc.: treat as transient, never as success.
      }

      if (attempt < maxAttempts) {
        await _wait(retryDelays[attempt - 1]);
      }
    }
    return PaymentCheckOutcome.notConfirmed;
  }
}

/// Where a pending payment is in its lifecycle. There is deliberately no
/// "success" phase: a confirmed payment is removed from the pending set.
enum PendingPaymentPhase {
  /// Checkout was opened in the browser; waiting for the user to come back.
  awaitingReturn,

  /// Calling the backend to confirm.
  verifying,

  /// The retry budget is spent without a `paid: true`. The user can retry.
  unconfirmed,
}

class PendingPayment {
  final int bookingId;
  final String reference;
  final DateTime startedAt;
  final PendingPaymentPhase phase;
  final int attempt;
  final int totalAttempts;

  const PendingPayment({
    required this.bookingId,
    required this.reference,
    required this.startedAt,
    this.phase = PendingPaymentPhase.awaitingReturn,
    this.attempt = 0,
    this.totalAttempts = 0,
  });

  PendingPayment copyWith({
    PendingPaymentPhase? phase,
    int? attempt,
    int? totalAttempts,
  }) {
    return PendingPayment(
      bookingId: bookingId,
      reference: reference,
      startedAt: startedAt,
      phase: phase ?? this.phase,
      attempt: attempt ?? this.attempt,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }
}
