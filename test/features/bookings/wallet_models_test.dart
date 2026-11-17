import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/network/api_exception.dart';
import 'package:workchop/features/bookings/data/datasources/wallet_remote_datasource.dart';
import 'package:workchop/features/bookings/data/models/wallet_response_models.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  test('balance parses string decimals and tolerates nulls', () {
    final m = WalletBalanceResponseModel.fromJson({
      'total_earned': '5000.00',
      'pending_release': 1250.5,
      'total_jobs_completed': 3,
      'total_jobs_paid': '2',
      'lifetime_earnings': null,
    });
    expect(m.totalEarned, 5000.0);
    expect(m.pendingRelease, 1250.5);
    expect(m.totalJobsPaid, 2);
    expect(m.lifetimeEarnings, 0.0);
    expect(m.toDomain().totalEarned, 5000.0);
  });

  test('earnings list maps items and summary', () {
    final m = WalletEarningsResponseModel.fromJson({
      'earnings': [
        {
          'payment_id': 9,
          'payment_reference': 'PAY-1',
          'booking_id': 42,
          'booking_reference': 'BK-1',
          'amount': '4500.00',
          'status': 'released',
          'customer_name': null,
          'job_date': '2030-05-01T10:00:00Z',
          'paid_at': '2030-05-01T11:00:00Z',
          'released_at': null,
          'created_at': '2030-05-01T09:00:00Z',
        },
      ],
      'total': 1,
      'summary': {'total_amount': '4500.00', 'count': 1},
    });
    expect(m.page, 1); // fallback
    expect(m.pageSize, 20); // fallback
    expect(m.summaryTotalAmount, 4500.0);
    final item = m.earnings.single;
    expect(item.amount, 4500.0);
    expect(item.customerName, 'Unknown'); // null -> default
    expect(item.releasedAt, isNull);
  });

  test('payout list tolerates an empty/missing array', () {
    final m = WalletPayoutsResponseModel.fromJson({'total': 0});
    expect(m.payouts, isEmpty);
  });

  test('datasource: balance round-trip and error mapping', () async {
    final ok = WalletRemoteDataSource(
      dio: fakeDio(
        (o) async => jsonResponse({
          'total_earned': '10.00',
          'pending_release': '0',
          'total_jobs_completed': 1,
          'total_jobs_paid': 1,
          'lifetime_earnings': '10.00',
        }),
      ),
    );
    expect((await ok.getWalletBalance()).totalEarned, 10.0);

    final forbidden = WalletRemoteDataSource(
      dio: fakeDio(
        (o) async => jsonResponse({'detail': 'Artisans only'}, status: 403),
      ),
    );
    await expectLater(
      forbidden.getWalletBalance(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'Artisans only')
            .having((e) => e.statusCode, 'status', 403),
      ),
    );

    final offline = WalletRemoteDataSource(dio: fakeDio(connectionError));
    await expectLater(
      offline.getWalletBalance(),
      throwsA(isA<NetworkException>()),
    );
  });
}
