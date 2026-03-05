class BookingProgressLog {
  final int id;
  final int bookingId;
  final String artisanId;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  const BookingProgressLog({
    required this.id,
    required this.bookingId,
    required this.artisanId,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });
}
