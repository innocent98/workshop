enum ArtisanBookingStatus {
  pending,
  accepted,
  paid,
  inProgress,
  completed,
  cancelled,
  rejected,
  disputed,
  unknown,
}

ArtisanBookingStatus artisanBookingStatusFromApi(String value) {
  switch (value) {
    case 'pending':
      return ArtisanBookingStatus.pending;
    case 'accepted':
      return ArtisanBookingStatus.accepted;
    case 'paid':
      return ArtisanBookingStatus.paid;
    case 'in_progress':
      return ArtisanBookingStatus.inProgress;
    case 'completed':
      return ArtisanBookingStatus.completed;
    case 'cancelled':
      return ArtisanBookingStatus.cancelled;
    case 'rejected':
      return ArtisanBookingStatus.rejected;
    case 'disputed':
      return ArtisanBookingStatus.disputed;
    default:
      return ArtisanBookingStatus.unknown;
  }
}

class ArtisanBooking {
  final int id;
  final String bookingReference;
  final String customerId;
  final String artisanId;
  final int serviceId;
  final String? customerName;
  final String? customerProfilePictureUrl;
  final String? customerPhoneNumber;
  final String? artisanName;
  final String? artisanProfilePictureUrl;
  final String? artisanPhoneNumber;
  final String? serviceName;
  final String? serviceImage;
  final String? jobDescription;
  final DateTime jobDate;
  final String jobAddress;
  final double? jobLatitude;
  final double? jobLongitude;
  final double budgetMin;
  final double budgetMax;
  final double? agreedAmount;
  final ArtisanBookingStatus status;
  final DateTime? acceptedAt;
  final DateTime? paidAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? completionNotes;
  final List<String>? completionImages;
  final String? cancellationReason;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArtisanBooking({
    required this.id,
    required this.bookingReference,
    required this.customerId,
    required this.artisanId,
    required this.serviceId,
    this.customerName,
    this.customerProfilePictureUrl,
    this.customerPhoneNumber,
    this.artisanName,
    this.artisanProfilePictureUrl,
    this.artisanPhoneNumber,
    this.serviceName,
    this.serviceImage,
    this.jobDescription,
    required this.jobDate,
    required this.jobAddress,
    this.jobLatitude,
    this.jobLongitude,
    required this.budgetMin,
    required this.budgetMax,
    this.agreedAmount,
    required this.status,
    this.acceptedAt,
    this.paidAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.completionNotes,
    this.completionImages,
    this.cancellationReason,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUpcoming =>
      status == ArtisanBookingStatus.pending ||
      status == ArtisanBookingStatus.accepted ||
      status == ArtisanBookingStatus.paid ||
      status == ArtisanBookingStatus.inProgress;

  bool get isHistory =>
      status == ArtisanBookingStatus.completed ||
      status == ArtisanBookingStatus.cancelled ||
      status == ArtisanBookingStatus.rejected;

  ArtisanBooking copyWith({
    ArtisanBookingStatus? status,
    double? agreedAmount,
    DateTime? acceptedAt,
    DateTime? paidAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? rejectionReason,
    String? completionNotes,
    List<String>? completionImages,
  }) {
    return ArtisanBooking(
      id: id,
      bookingReference: bookingReference,
      customerId: customerId,
      artisanId: artisanId,
      serviceId: serviceId,
      customerName: customerName,
      customerProfilePictureUrl: customerProfilePictureUrl,
      customerPhoneNumber: customerPhoneNumber,
      artisanName: artisanName,
      artisanProfilePictureUrl: artisanProfilePictureUrl,
      artisanPhoneNumber: artisanPhoneNumber,
      serviceName: serviceName,
      serviceImage: serviceImage,
      jobDescription: jobDescription,
      jobDate: jobDate,
      jobAddress: jobAddress,
      jobLatitude: jobLatitude,
      jobLongitude: jobLongitude,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      agreedAmount: agreedAmount ?? this.agreedAmount,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      paidAt: paidAt ?? this.paidAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completionNotes: completionNotes ?? this.completionNotes,
      completionImages: completionImages ?? this.completionImages,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
