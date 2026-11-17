import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/widgets/inputs/app_text_field.dart';

void main() {
  testWidgets('a shown validation error clears as soon as the text is valid', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                controller: controller,
                label: 'Email',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please enter your email'
                    : (!v.contains('@') ? 'Please enter a valid email' : null),
              ),
            ),
          ),
        ),
      ),
    );

    // Submit with an empty field: error appears.
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);

    // First keystroke: error is re-evaluated (now a different one).
    await tester.enterText(find.byType(TextFormField), 'a');
    await tester.pump();
    expect(find.text('Please enter your email'), findsNothing);
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Valid text: error disappears without another submit.
    await tester.enterText(find.byType(TextFormField), 'a@b.co');
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsNothing);
  });

  testWidgets('does not show an error while typing before any submit', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Form(
              child: AppTextField(
                controller: controller,
                validator: (v) => v == 'ok' ? null : 'bad',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'o');
    await tester.pump();
    expect(find.text('bad'), findsNothing);
  });
}
