import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/profile/presentation/widgets/delete_account_dialog.dart';

/// Opens the dialog from a button and records what it popped with.
Widget _host(Future<void> Function() onConfirm, {List<bool?>? results}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final r = await showDialog<bool>(
                  context: context,
                  builder: (_) => DeleteAccountDialog(onConfirm: onConfirm),
                );
                results?.add(r);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Finder get _confirmButton => find.byKey(const Key('delete_account_confirm'));

bool _confirmEnabled(WidgetTester tester) =>
    tester.widget<TextButton>(_confirmButton).onPressed != null;

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('explains what is lost and keeps confirm disabled', (
    tester,
  ) async {
    await tester.pumpWidget(_host(() async {}));
    await _open(tester);

    expect(find.textContaining('permanent'), findsOneWidget);
    expect(find.textContaining('booking and job history'), findsOneWidget);
    expect(_confirmEnabled(tester), isFalse);
  });

  testWidgets('confirm enables only when DELETE is typed exactly', (
    tester,
  ) async {
    await tester.pumpWidget(_host(() async {}));
    await _open(tester);
    final field = find.byKey(const Key('delete_account_confirm_field'));

    await tester.enterText(field, 'DELET');
    await tester.pump();
    expect(_confirmEnabled(tester), isFalse);

    await tester.enterText(field, 'delete');
    await tester.pump();
    expect(_confirmEnabled(tester), isFalse);

    await tester.enterText(field, 'DELETE');
    await tester.pump();
    expect(_confirmEnabled(tester), isTrue);

    await tester.enterText(field, 'DELETE ME');
    await tester.pump();
    expect(_confirmEnabled(tester), isFalse);
  });

  testWidgets('success shows loading, calls onConfirm once, pops true', (
    tester,
  ) async {
    final completer = Completer<void>();
    var calls = 0;
    final results = <bool?>[];
    await tester.pumpWidget(
      _host(() {
        calls++;
        return completer.future;
      }, results: results),
    );
    await _open(tester);
    await tester.enterText(
      find.byKey(const Key('delete_account_confirm_field')),
      'DELETE',
    );
    await tester.pump();

    await tester.tap(_confirmButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_confirmEnabled(tester), isFalse);
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('delete_account_cancel')))
          .onPressed,
      isNull,
      reason: 'cannot cancel mid-request',
    );

    completer.complete();
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(results, [true]);
    expect(find.byType(DeleteAccountDialog), findsNothing);
  });

  testWidgets('failure stays open, shows the reason and allows retry', (
    tester,
  ) async {
    var calls = 0;
    final results = <bool?>[];
    await tester.pumpWidget(
      _host(() async {
        calls++;
        if (calls == 1) throw NetworkException();
      }, results: results),
    );
    await _open(tester);
    await tester.enterText(
      find.byKey(const Key('delete_account_confirm_field')),
      'DELETE',
    );
    await tester.pump();

    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAccountDialog), findsOneWidget);
    expect(find.byKey(const Key('delete_account_error')), findsOneWidget);
    expect(find.textContaining('still signed in'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(_confirmEnabled(tester), isTrue);
    expect(results, isEmpty);

    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(results, [true]);
  });

  testWidgets('cancel pops false without deleting', (tester) async {
    var calls = 0;
    final results = <bool?>[];
    await tester.pumpWidget(_host(() async => calls++, results: results));
    await _open(tester);

    await tester.tap(find.byKey(const Key('delete_account_cancel')));
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(results, [false]);
  });
}
