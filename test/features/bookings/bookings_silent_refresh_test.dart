import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/bookings/data/datasources/artisan_bookings_remote_datasource.dart';
import 'package:workchop/features/bookings/data/repositories/artisan_bookings_repository_impl.dart';
import 'package:workchop/features/bookings/presentation/providers/artisan_bookings_provider.dart';

import '../../helpers/booking_fixtures.dart';
import '../../helpers/fake_http_adapter.dart';

Map<String, dynamic> _list(List<Map<String, dynamic>> bookings) => {
  'bookings': bookings,
  'total': bookings.length,
  'page': 1,
  'page_size': 100,
};

void main() {
  late List<Map<String, dynamic>> server;
  late bool offline;
  late int listCalls;
  late ProviderContainer container;
  late List<AsyncValue<List<dynamic>>> states;

  setUp(() {
    server = [];
    offline = false;
    listCalls = 0;
    states = [];
    final dio = fakeDio((o) async {
      listCalls++;
      if (offline) return connectionError(o);
      return jsonResponse(_list(server));
    });
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        artisanBookingsRepositoryProvider.overrideWithValue(
          ArtisanBookingsRepositoryImpl(
            remoteDataSource: ArtisanBookingsRemoteDataSource(dio: dio),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(
      artisanBookingsProvider,
      (_, next) => states.add(next),
      fireImmediately: false,
    );
  });

  test(
    'after a booking is created, a silent refresh shows it with no spinner',
    () async {
      // Tab already loaded and showing the empty state.
      expect(await container.read(artisanBookingsProvider.future), isEmpty);
      states.clear();

      // POST /bookings 201 happened: the server now has one booking.
      server = [bookingJson(id: 1, status: 'pending')];
      await container.read(artisanBookingsProvider.notifier).refreshSilently();

      expect(
        container.read(artisanBookingsProvider).requireValue,
        hasLength(1),
      );
      expect(
        states.any((s) => s.isLoading),
        isFalse,
        reason: 'existing list must stay visible; no full-screen spinner',
      );
    },
  );

  test(
    'a failed silent refresh keeps the list that is already on screen',
    () async {
      server = [bookingJson(id: 1, status: 'pending')];
      await container.read(artisanBookingsProvider.future);

      offline = true;
      await container.read(artisanBookingsProvider.notifier).refreshSilently();

      final state = container.read(artisanBookingsProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue, hasLength(1));
    },
  );

  test(
    'a failed silent refresh with nothing to show surfaces the error',
    () async {
      offline = true;
      final notifier = container.read(artisanBookingsProvider.notifier);
      // Initial build fails too; wait for it, then retry silently.
      await container
          .read(artisanBookingsProvider.future)
          .then<void>((_) {}, onError: (_) {});
      await notifier.refreshSilently();

      expect(container.read(artisanBookingsProvider).hasError, isTrue);
    },
  );

  test('concurrent silent refreshes share one request', () async {
    await container.read(artisanBookingsProvider.future);
    listCalls = 0;
    final notifier = container.read(artisanBookingsProvider.notifier);

    await Future.wait([
      notifier.refreshSilently(),
      notifier.refreshSilently(),
      notifier.refreshSilently(),
    ]);

    expect(listCalls, 1);
  });
}
