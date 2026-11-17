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
  Future<ArtisanBooking> logProgress({
    required int bookingId,
    required String description,
    String? imagePath,
  }) async {
    await _remoteDataSource.logProgress(
      bookingId: bookingId,
      description: description,
      imagePath: imagePath,
    );
    final refreshed = await _remoteDataSource.getBooking(bookingId);
    return refreshed.toDomain();
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

  @override
  Future<ArtisanBooking> cancelBooking({
    required int bookingId,
    required String cancellationReason,
  }) async {
    final response = await _remoteDataSource.cancelBooking(
      bookingId: bookingId,
      cancellationReason: cancellationReason,
    );
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> confirmCompletion({required int bookingId}) async {
    final response = await _remoteDataSource.confirmCompletion(
      bookingId: bookingId,
    );
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> disputeCompletion({
    required int bookingId,
    required String disputeReason,
  }) async {
    final response = await _remoteDataSource.disputeCompletion(
      bookingId: bookingId,
      disputeReason: disputeReason,
    );
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> negotiateBooking({
    required int bookingId,
    required double negotiatedAmount,
    required String negotiationCondition,
  }) async {
    final response = await _remoteDataSource.negotiateBooking(
      bookingId: bookingId,
      negotiatedAmount: negotiatedAmount,
      negotiationCondition: negotiationCondition,
    );
    return response.toDomain();
  }

  @override
  Future<ArtisanBooking> respondToNegotiation({
    required int bookingId,
    required String action,
    double? negotiatedAmount,
    String? negotiationCondition,
  }) async {
    final response = await _remoteDataSource.respondToNegotiation(
      bookingId: bookingId,
      action: action,
      negotiatedAmount: negotiatedAmount,
      negotiationCondition: negotiationCondition,
    );
    return response.toDomain();
  }
}
