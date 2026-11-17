import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/bookings/domain/payment_verification.dart';
import 'package:workchop/features/bookings/presentation/widgets/pending_payment_banner.dart';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

PendingPayment _payment(
  PendingPaymentPhase phase, {
  int attempt = 0,
  int total = 0,
}) => PendingPayment(
  bookingId: 1,
  reference: 'REF',
  startedAt: DateTime(2030),
  phase: phase,
  attempt: attempt,
  totalAttempts: total,
);

void main() {
  testWidgets(
    'verifying shows "Confirming payment..." with progress, no buttons',
    (tester) async {
      await tester.pumpWidget(
        _host(
          PendingPaymentBanner(
            payment: _payment(
              PendingPaymentPhase.verifying,
              attempt: 2,
              total: 5,
            ),
            onCheckAgain: () {},
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Confirming payment...'), findsOneWidget);
      expect(find.textContaining('attempt 2 of 5'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.byKey(const Key('pending_payment_check_again')),
        findsNothing,
      );
      // Never claims success while pending.
      expect(find.textContaining('confirmed'), findsNothing);
      expect(find.textContaining('successful'), findsNothing);
    },
  );

  testWidgets('unconfirmed offers a manual check and a dismiss', (
    tester,
  ) async {
    var checks = 0;
    var dismissed = 0;
    await tester.pumpWidget(
      _host(
        PendingPaymentBanner(
          payment: _payment(PendingPaymentPhase.unconfirmed),
          onCheckAgain: () => checks++,
          onDismiss: () => dismissed++,
        ),
      ),
    );

    expect(find.text('Payment not confirmed'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byKey(const Key('pending_payment_check_again')));
    await tester.tap(find.byKey(const Key('pending_payment_dismiss')));
    expect(checks, 1);
    expect(dismissed, 1);
    expect(find.text("I've paid, check again"), findsOneWidget);
  });

  testWidgets('awaiting return tells the user to finish in the browser', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        PendingPaymentBanner(
          payment: _payment(PendingPaymentPhase.awaitingReturn),
          onCheckAgain: () {},
          onDismiss: () {},
        ),
      ),
    );
    expect(
      find.textContaining('Finish paying in your browser'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('pending_payment_check_again')),
      findsOneWidget,
    );
  });
}
