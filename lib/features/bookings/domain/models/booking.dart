class Booking {
  final String id;
  final String artisanName;
  final String artisanAvatar;
  final String serviceType;
  final bool isVerified;
  final String status; // 'requested', 'ongoing', 'completed'
  final DateTime dateTime;
  final List<String> services;

  /// Client's budget range, when the booking carries one.
  final double? budgetMin;
  final double? budgetMax;

  /// True once the client disputed the artisan's completion claim.
  final bool isDisputed;
  final String? disputeReason;

  Booking({
    required this.id,
    required this.artisanName,
    required this.artisanAvatar,
    required this.serviceType,
    required this.isVerified,
    required this.status,
    required this.dateTime,
    required this.services,
    this.budgetMin,
    this.budgetMax,
    this.isDisputed = false,
    this.disputeReason,
  });
}
