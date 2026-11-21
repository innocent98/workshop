import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/core/providers/session_reset.dart';
import 'package:workchop/features/artisan_profile/domain/models/review.dart';
import 'package:workchop/features/artisan_profile/domain/models/review_report_reason.dart';
import 'package:workchop/features/artisan_profile/domain/repositories/artisan_public_profile_repository.dart';
import 'package:workchop/features/artisan_profile/presentation/providers/artisan_public_profile_providers.dart';
import 'package:workchop/features/artisan_profile/presentation/providers/report_review_provider.dart';
import 'package:workchop/features/artisan_profile/presentation/widgets/review_item_widget.dart';

class _FakeRepo implements ArtisanPublicProfileRepository {
  _FakeRepo({this.error});

  final Object? error;
  final List<(String, ReviewReportReason)> calls = [];

  @override
  Future<void> reportReview(
    String reviewId,
    ReviewReportReason reason, {
    String? details,
  }) async {
    calls.add((reviewId, reason));
    if (error != null) throw error!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Review _review({String id = '1', String? customerId = 'other-user'}) => Review(
  id: id,
  customerId: customerId,
  reviewerName: 'Customer One',
  reviewerAvatarUrl: '',
  rating: 4,
  comment: 'Great job',
  date: DateTime(2026, 11, 18, 22, 7),
  createdAt: DateTime(2026, 11, 18, 22, 7),
);

Widget _host(_FakeRepo repo, List<Review> reviews, {String? me = 'me'}) {
  return ProviderScope(
    overrides: [
      artisanPublicProfileRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue(me),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [for (final r in reviews) ReviewItemWidget(review: r)],
            ),
          ),
        ),
      ),
    ),
  );
}

final _reportButton = find.byKey(const Key('review_report_button'));
final _reportedLabel = find.byKey(const Key('review_reported_label'));
final _confirm = find.byKey(const Key('report_review_confirm'));

Future<void> _openAndPick(WidgetTester tester, String reason) async {
  await tester.tap(_reportButton);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('report_reason_$reason')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hidden on the viewer\'s own review', (tester) async {
    await tester.pumpWidget(_host(_FakeRepo(), [_review(customerId: 'me')]));
    expect(_reportButton, findsNothing);
    expect(_reportedLabel, findsNothing);
  });

  testWidgets(
    'shown on someone else\'s review and when the author is unknown',
    (tester) async {
      await tester.pumpWidget(
        _host(_FakeRepo(), [
          _review(id: '1'),
          _review(id: '2', customerId: null),
        ]),
      );
      expect(_reportButton, findsNWidgets(2));
    },
  );

  testWidgets(
    'confirm stays disabled until a reason is chosen; cancel sends nothing',
    (tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(_host(repo, [_review()]));

      await tester.tap(_reportButton);
      await tester.pumpAndSettle();
      expect(tester.widget<TextButton>(_confirm).onPressed, isNull);

      await tester.tap(find.byKey(const Key('report_review_cancel')));
      await tester.pumpAndSettle();

      expect(repo.calls, isEmpty);
      expect(_reportButton, findsOneWidget);
    },
  );

  testWidgets('success: calls the API once, shows a snackbar, marks reported', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(_host(repo, [_review(id: '7')]));

    await _openAndPick(tester, 'fake');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    expect(repo.calls, [('7', ReviewReportReason.fake)]);
    expect(find.text('Thanks, our team will take a look.'), findsOneWidget);
    expect(_reportedLabel, findsOneWidget);
    expect(_reportButton, findsNothing); // cannot be reported twice in-session
  });

  testWidgets('reporting one review leaves the others reportable', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(_host(repo, [_review(id: '1'), _review(id: '2')]));

    await tester.tap(_reportButton.first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report_reason_spam')));
    await tester.pumpAndSettle();
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    expect(repo.calls.single.$1, '1');
    expect(_reportedLabel, findsOneWidget);
    expect(_reportButton, findsOneWidget);
  });

  testWidgets('409 already_reported: friendly message, treated as reported', (
    tester,
  ) async {
    final repo = _FakeRepo(
      error: ApiException(
        "You've already reported this review.",
        409,
        'already_reported',
      ),
    );
    await tester.pumpWidget(_host(repo, [_review()]));

    await _openAndPick(tester, 'abusive');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    expect(find.text("You've already reported this review."), findsOneWidget);
    expect(_reportedLabel, findsOneWidget);
  });

  testWidgets('429 rate limited: shows the message, review stays reportable', (
    tester,
  ) async {
    final repo = _FakeRepo(
      error: ApiException(
        'You have reported too many reviews recently. Please try again later.',
        429,
        'report_rate_limited',
      ),
    );
    await tester.pumpWidget(_host(repo, [_review()]));

    await _openAndPick(tester, 'other');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'You have reported too many reviews recently. Please try again later.',
      ),
      findsOneWidget,
    );
    expect(_reportedLabel, findsNothing);
    expect(_reportButton, findsOneWidget);
  });

  testWidgets('404 and offline show their messages and do not mark reported', (
    tester,
  ) async {
    final repo = _FakeRepo(
      error: ApiException(
        'This review is no longer available.',
        404,
        'review_not_found',
      ),
    );
    await tester.pumpWidget(_host(repo, [_review()]));
    await _openAndPick(tester, 'spam');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    expect(find.text('This review is no longer available.'), findsOneWidget);
    expect(_reportedLabel, findsNothing);

    final offline = _FakeRepo(error: NetworkException());
    await tester.pumpWidget(_host(offline, [_review()]));
    await _openAndPick(tester, 'spam');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    expect(
      find.text('Network error occurred. Please check your connection.'),
      findsOneWidget,
    );
    expect(_reportedLabel, findsNothing);
  });

  test(
    'reported ids are session-scoped: cleared when the account signs out',
    () {
      expect(userScopedProviders, contains(reportedReviewIdsProvider));
    },
  );
}
