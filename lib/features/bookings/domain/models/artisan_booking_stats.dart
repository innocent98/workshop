class ArtisanBookingStats {
  final int totalBookings;
  final int pendingBookings;
  final int acceptedBookings;
  final int paidBookings;
  final int inProgressBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int rejectedBookings;
  final int disputedBookings;

  const ArtisanBookingStats({
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
}
