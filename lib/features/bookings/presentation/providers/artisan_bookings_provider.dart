import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/artisan_bookings_repository_impl.dart';
import '../../domain/models/artisan_booking.dart';
import '../../domain/models/artisan_booking_stats.dart';
import '../../domain/repositories/artisan_bookings_repository.dart';

final artisanBookingsRepositoryProvider = Provider<ArtisanBookingsRepository>((
  ref,
) {
  return ArtisanBookingsRepositoryImpl();
});

final artisanBookingsProvider =
    AsyncNotifierProvider<ArtisanBookingsNotifier, List<ArtisanBooking>>(
      ArtisanBookingsNotifier.new,
    );

class ArtisanBookingsNotifier extends AsyncNotifier<List<ArtisanBooking>> {
  @override
  Future<List<ArtisanBooking>> build() async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    return repository.listBookings();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(artisanBookingsRepositoryProvider);
      return repository.listBookings();
    });
  }

  Future<ArtisanBooking> getBooking(int bookingId) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final booking = await repository.getBooking(bookingId);

    if (state.value != null) {
      final updated = [
        for (final item in state.value!)
          if (item.id == booking.id) booking else item,
      ];
      if (!updated.any((item) => item.id == booking.id)) {
        updated.insert(0, booking);
      }
      state = AsyncValue.data(updated);
    }

    return booking;
  }

  Future<ArtisanBooking> acceptBooking({
    required int bookingId,
    required double agreedAmount,
  }) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.acceptBooking(
      bookingId: bookingId,
      agreedAmount: agreedAmount,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> rejectBooking({
    required int bookingId,
    required String rejectionReason,
  }) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.rejectBooking(
      bookingId: bookingId,
      rejectionReason: rejectionReason,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> startBooking({required int bookingId}) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.startBooking(bookingId: bookingId);
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> completeBooking({
    required int bookingId,
    String? completionNotes,
    List<String>? completionImages,
  }) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.completeBooking(
      bookingId: bookingId,
      completionNotes: completionNotes,
      completionImages: completionImages,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> cancelBooking({
    required int bookingId,
    required String cancellationReason,
  }) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.cancelBooking(
      bookingId: bookingId,
      cancellationReason: cancellationReason,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> confirmCompletion({required int bookingId}) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.confirmCompletion(
      bookingId: bookingId,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> negotiateBooking({
    required int bookingId,
    required double negotiatedAmount,
    required String negotiationCondition,
  }) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.negotiateBooking(
      bookingId: bookingId,
      negotiatedAmount: negotiatedAmount,
      negotiationCondition: negotiationCondition,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  Future<ArtisanBooking> respondToNegotiation({
    required int bookingId,
    required String action,
    double? negotiatedAmount,
    String? negotiationCondition,
  }) async {
    final repository = ref.read(artisanBookingsRepositoryProvider);
    final updatedBooking = await repository.respondToNegotiation(
      bookingId: bookingId,
      action: action,
      negotiatedAmount: negotiatedAmount,
      negotiationCondition: negotiationCondition,
    );
    _upsertBooking(updatedBooking);
    return updatedBooking;
  }

  void _upsertBooking(ArtisanBooking booking) {
    final current = state.value;
    if (current == null) {
      state = AsyncValue.data([booking]);
      return;
    }

    final existingIndex = current.indexWhere((item) => item.id == booking.id);
    final updated = [...current];

    if (existingIndex >= 0) {
      updated[existingIndex] = booking;
    } else {
      updated.insert(0, booking);
    }

    state = AsyncValue.data(updated);
  }
}

final artisanBookingDetailsProvider =
    FutureProvider.family<ArtisanBooking, int>((ref, bookingId) async {
      final notifier = ref.read(artisanBookingsProvider.notifier);
      return notifier.getBooking(bookingId);
    });

final artisanBookingStatsProvider = FutureProvider<ArtisanBookingStats>((
  ref,
) async {
  final repository = ref.read(artisanBookingsRepositoryProvider);
  return repository.getBookingStats();
});
