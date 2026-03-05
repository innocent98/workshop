import '../models/artisan_booking.dart';
import '../models/artisan_booking_stats.dart';

abstract class ArtisanBookingsRepository {
  Future<List<ArtisanBooking>> listBookings({String? statusFilter});

  Future<ArtisanBooking> getBooking(int bookingId);

  Future<ArtisanBookingStats> getBookingStats();

  Future<ArtisanBooking> acceptBooking({
    required int bookingId,
    required double agreedAmount,
  });

  Future<ArtisanBooking> rejectBooking({
    required int bookingId,
    required String rejectionReason,
  });

  Future<ArtisanBooking> startBooking({required int bookingId});

  Future<ArtisanBooking> logProgress({
    required int bookingId,
    required String description,
    String? imagePath,
  });

  Future<ArtisanBooking> completeBooking({
    required int bookingId,
    String? completionNotes,
    List<String>? completionImages,
  });

  Future<ArtisanBooking> cancelBooking({
    required int bookingId,
    required String cancellationReason,
  });

  Future<ArtisanBooking> confirmCompletion({required int bookingId});

  Future<ArtisanBooking> negotiateBooking({
    required int bookingId,
    required double negotiatedAmount,
    required String negotiationCondition,
  });

  Future<ArtisanBooking> respondToNegotiation({
    required int bookingId,
    required String action,
    double? negotiatedAmount,
    String? negotiationCondition,
  });
}
