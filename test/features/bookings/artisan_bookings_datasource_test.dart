import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/bookings/data/datasources/artisan_bookings_remote_datasource.dart';
import 'package:workchop/features/bookings/data/repositories/artisan_bookings_repository_impl.dart';
import 'package:workchop/features/bookings/domain/models/artisan_booking.dart';

import '../../helpers/booking_fixtures.dart';
import '../../helpers/fake_http_adapter.dart';

void main() {
  test('listBookings maps decimals-as-strings and nested logs', () async {
    final dio = fakeDio(
      (o) async => jsonResponse({
        'bookings': [bookingJson()],
        'total': 1,
        'page': 1,
        'page_size': 100,
      }),
    );
    final repo = ArtisanBookingsRepositoryImpl(
      remoteDataSource: ArtisanBookingsRemoteDataSource(dio: dio),
    );

    final bookings = await repo.listBookings();

    expect(bookings, hasLength(1));
    final b = bookings.single;
    expect(b.id, 42);
    expect(b.status, ArtisanBookingStatus.completed);
    expect(b.budgetMin, 5000.0);
    expect(b.jobLatitude, 6.5244); // string in the payload
    expect(b.jobLongitude, 3.3792); // number in the payload
    expect(b.agreedAmount, 6500.0);
    expect(b.progressLogs.single.description, 'Started work'); // trimmed
    expect(b.completionDisputedAt, isNull);
  });

  test('unknown status does not crash', () async {
    final dio = fakeDio(
      (o) async => jsonResponse(bookingJson(status: 'something_new')),
    );
    final b = await ArtisanBookingsRepositoryImpl(
      remoteDataSource: ArtisanBookingsRemoteDataSource(dio: dio),
    ).getBooking(42);
    expect(b.status, ArtisanBookingStatus.unknown);
  });

  group('disputeCompletion', () {
    test(
      'PATCHes the trimmed reason and returns the disputed booking',
      () async {
        late FakeHttpAdapter adapter;
        final dio = fakeDio((o) async {
          return jsonResponse(
            bookingJson(
              status: 'disputed',
              disputedAt: '2030-05-02T08:00:00Z',
              disputeReason: 'The leak is still there',
            ),
          );
        }, adapter: (a) => adapter = a);
        final repo = ArtisanBookingsRepositoryImpl(
          remoteDataSource: ArtisanBookingsRemoteDataSource(dio: dio),
        );

        final b = await repo.disputeCompletion(
          bookingId: 42,
          disputeReason: '  The leak is still there  ',
        );

        final req = adapter.requests.single;
        expect(req.method, 'PATCH');
        expect(req.path, '/bookings/42/dispute-completion');
        expect(req.data, {'dispute_reason': 'The leak is still there'});
        expect(b.status, ArtisanBookingStatus.disputed);
        expect(b.completionDisputeReason, 'The leak is still there');
        expect(b.completionDisputedAt, isNotNull);
      },
    );

    test('surfaces the backend error text (window elapsed)', () async {
      final dio = fakeDio(
        (o) async =>
            jsonResponse({'detail': 'Dispute window has elapsed'}, status: 400),
      );
      final ds = ArtisanBookingsRemoteDataSource(dio: dio);

      await expectLater(
        ds.disputeCompletion(bookingId: 42, disputeReason: 'Not done properly'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Dispute window has elapsed')
              .having((e) => e.statusCode, 'status', 400),
        ),
      );
    });

    test('offline becomes NetworkException, not DioException', () async {
      final ds = ArtisanBookingsRemoteDataSource(dio: fakeDio(connectionError));
      await expectLater(
        ds.disputeCompletion(bookingId: 42, disputeReason: 'Not done properly'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  test('confirmCompletion hits the confirm endpoint', () async {
    late FakeHttpAdapter adapter;
    final dio = fakeDio(
      (o) async =>
          jsonResponse(bookingJson(confirmedAt: '2030-05-02T08:00:00Z')),
      adapter: (a) => adapter = a,
    );
    final b = await ArtisanBookingsRemoteDataSource(
      dio: dio,
    ).confirmCompletion(bookingId: 42);
    expect(adapter.requests.single.path, '/bookings/42/confirm-completion');
    expect(b.completionConfirmedByClientAt, isNotNull);
  });
}
