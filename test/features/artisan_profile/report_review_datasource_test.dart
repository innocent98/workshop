import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/artisan_profile/data/datasources/artisan_public_profile_remote_datasource.dart';
import 'package:workchop/features/artisan_profile/data/models/reviews_response_model.dart';
import 'package:workchop/features/artisan_profile/data/repositories/artisan_public_profile_repository_impl.dart';
import 'package:workchop/features/artisan_profile/domain/models/review_report_reason.dart';

import '../../helpers/fake_http_adapter.dart';

// Error bodies copied from the backend's captured responses 21, 22, 23, 26.
const _alreadyReported = {
  'detail': {
    'code': 'already_reported',
    'message': 'You have already reported this review.',
  },
};
const _ownReview = {
  'detail': {
    'code': 'cannot_report_own_review',
    'message': 'You cannot report your own review.',
  },
};
const _notFound = {
  'detail': {'code': 'review_not_found', 'message': 'Review not found'},
};
const _rateLimited = {
  'detail': {
    'code': 'report_rate_limited',
    'message':
        'You have reported too many reviews recently. Please try again later.',
  },
};

void main() {
  FakeHttpAdapter? adapter;

  ArtisanPublicProfileRepositoryImpl repoFor(FakeHandler handler) {
    final source = ArtisanPublicProfileRemoteDataSource(
      dio: fakeDio(handler, adapter: (a) => adapter = a),
    );
    return ArtisanPublicProfileRepositoryImpl(dataSource: source);
  }

  Future<ApiException> failWith(Object body, int status) async {
    final repo = repoFor((o) async => jsonResponse(body, status: status));
    try {
      await repo.reportReview('1', ReviewReportReason.fake);
    } on ApiException catch (e) {
      return e;
    }
    fail('expected an ApiException');
  }

  test(
    'success: POST /reviews/{id}/report with the reason (no details)',
    () async {
      final repo = repoFor(
        (o) async =>
            jsonResponse({'review_id': 1, 'reported': true}, status: 201),
      );

      await repo.reportReview('1', ReviewReportReason.fake);

      final request = adapter!.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/reviews/1/report');
      expect(request.data, {'reason': 'fake'});
    },
  );

  test('details are sent trimmed, and omitted when blank', () async {
    final source = ArtisanPublicProfileRemoteDataSource(
      dio: fakeDio(
        (o) async =>
            jsonResponse({'review_id': 1, 'reported': true}, status: 201),
        adapter: (a) => adapter = a,
      ),
    );
    await source.reportReview(
      '1',
      ReviewReportReason.other,
      details: '  I do not know this customer.  ',
    );
    expect(adapter!.requests.last.data, {
      'reason': 'other',
      'details': 'I do not know this customer.',
    });

    await source.reportReview('1', ReviewReportReason.spam, details: '   ');
    expect(adapter!.requests.last.data, {'reason': 'spam'});
  });

  test('409 already_reported -> friendly message, code kept', () async {
    final e = await failWith(_alreadyReported, 409);
    expect(e.code, 'already_reported');
    expect(e.statusCode, 409);
    expect(e.message, "You've already reported this review.");
  });

  test('403 cannot_report_own_review -> friendly message', () async {
    final e = await failWith(_ownReview, 403);
    expect(e.message, "You can't report your own review.");
    expect(e.code, 'cannot_report_own_review');
  });

  test('404 review_not_found -> friendly message', () async {
    final e = await failWith(_notFound, 404);
    expect(e.statusCode, 404);
    expect(e.message, 'This review is no longer available.');
  });

  test('429 report_rate_limited -> uses the backend message', () async {
    final e = await failWith(_rateLimited, 429);
    expect(e.code, 'report_rate_limited');
    expect(
      e.message,
      'You have reported too many reviews recently. Please try again later.',
    );
  });

  test(
    '429 with an unknown body (per-IP limit, not captured) -> generic slow-down',
    () async {
      final e = await failWith({'detail': 'Rate limit exceeded'}, 429);
      expect(e.statusCode, 429);
      expect(
        e.message,
        "You've sent too many reports. Please try again later.",
      );
    },
  );

  test('422 never leaks the validation text', () async {
    final e = await failWith({
      'detail': [
        {'msg': "Input should be 'abusive', 'spam', 'fake' or 'other'"},
      ],
    }, 422);
    expect(e.message, "Couldn't send your report. Please try again.");
  });

  test('offline -> NetworkException', () async {
    final repo = repoFor(connectionError);
    await expectLater(
      repo.reportReview('1', ReviewReportReason.abusive),
      throwsA(isA<NetworkException>()),
    );
  });

  test('review list parsing keeps customer_id (null when absent)', () {
    final model = ReviewsResponseModel.fromJson({
      'reviews': [
        {
          'id': 3,
          'customer_id': '6e254903-d37c-4255-bb49-4313a27f9d16',
          'rating': 3.0,
          'review_text': 'Decent job',
          'customer_name': 'Customer Three',
          'created_at': '2026-11-18T22:07:26.171264Z',
        },
        {'id': 4, 'rating': 5.0, 'created_at': '2026-11-18T22:07:07Z'},
      ],
      'total': 2,
      'average_rating': 4.0,
      'rating_distribution': {'3': 1, '5': 1},
    }).toDomain();

    expect(model.reviews[0].customerId, '6e254903-d37c-4255-bb49-4313a27f9d16');
    expect(model.reviews[0].id, '3');
    expect(model.reviews[1].customerId, isNull);
  });
}
