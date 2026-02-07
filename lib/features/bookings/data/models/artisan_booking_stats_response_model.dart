import '../../domain/models/artisan_booking_stats.dart';

class ArtisanBookingStatsResponseModel {
  final int totalBookings;
  final int pendingBookings;
  final int acceptedBookings;
  final int paidBookings;
  final int inProgressBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int rejectedBookings;
  final int disputedBookings;

  const ArtisanBookingStatsResponseModel({
    required this.totalBookings,
    required this.pendingBookings,
    required this.acceptedBookings,
    required this.paidBookings,
    required this.inProgressBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.rejectedBookings,
    required this.disputedBookings,
  });

  factory ArtisanBookingStatsResponseModel.fromJson(Map<String, dynamic> json) {
    int parseInt(String key) => (json[key] as num?)?.toInt() ?? 0;

    return ArtisanBookingStatsResponseModel(
      totalBookings: parseInt('total_bookings'),
      pendingBookings: parseInt('pending_bookings'),
      acceptedBookings: parseInt('accepted_bookings'),
      paidBookings: parseInt('paid_bookings'),
      inProgressBookings: parseInt('in_progress_bookings'),
      completedBookings: parseInt('completed_bookings'),
      cancelledBookings: parseInt('cancelled_bookings'),
      rejectedBookings: parseInt('rejected_bookings'),
      disputedBookings: parseInt('disputed_bookings'),
    );
  }

  ArtisanBookingStats toDomain() {
    return ArtisanBookingStats(
      totalBookings: totalBookings,
      pendingBookings: pendingBookings,
      acceptedBookings: acceptedBookings,
      paidBookings: paidBookings,
      inProgressBookings: inProgressBookings,
      completedBookings: completedBookings,
      cancelledBookings: cancelledBookings,
      rejectedBookings: rejectedBookings,
      disputedBookings: disputedBookings,
    );
  }
}
