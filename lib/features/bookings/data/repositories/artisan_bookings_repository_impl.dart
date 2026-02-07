import '../../domain/models/artisan_booking.dart';
import '../../domain/models/artisan_booking_stats.dart';
import '../../domain/repositories/artisan_bookings_repository.dart';
import '../datasources/artisan_bookings_remote_datasource.dart';

class ArtisanBookingsRepositoryImpl implements ArtisanBookingsRepository {
  final ArtisanBookingsRemoteDataSource _remoteDataSource;

  ArtisanBookingsRepositoryImpl({
    ArtisanBookingsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? ArtisanBookingsRemoteDataSource();

  @override
  Future<List<ArtisanBooking>> listBookings({String? statusFilter}) async {
    final response = await _remoteDataSource.listBookings(
      statusFilter: statusFilter,
    );
    return response.bookings.map((item) => item.toDomain()).toList();
  }

  @override
  Future<ArtisanBooking> getBooking(int bookingId) async {
    final response = await _remoteDataSource.getBooking(bookingId);
    return response.toDomain();
  }

  @override
  Future<ArtisanBookingStats> getBookingStats() async {
    final response = await _remoteDataSource.getBookingStats();
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> acceptBooking({
    required int bookingId,
    required double agreedAmount,
  }) async {
    final response = await _remoteDataSource.acceptBooking(
      bookingId: bookingId,
      agreedAmount: agreedAmount,
    );
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> rejectBooking({
    required int bookingId,
    required String rejectionReason,
  }) async {
    final response = await _remoteDataSource.rejectBooking(
      bookingId: bookingId,
      rejectionReason: rejectionReason,
    );
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> startBooking({required int bookingId}) async {
    final response = await _remoteDataSource.startBooking(bookingId: bookingId);
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> completeBooking({
    required int bookingId,
    String? completionNotes,
    List<String>? completionImages,
  }) async {
    final response = await _remoteDataSource.completeBooking(
      bookingId: bookingId,
      completionNotes: completionNotes,
      completionImages: completionImages,
    );
    return response.toDomain();
  }
}
