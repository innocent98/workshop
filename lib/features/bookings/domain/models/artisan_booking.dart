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
  final double? negotiatedAmount;
  final String? negotiationCondition;
  final String negotiationStatus;
  final String? negotiationLastOfferBy;
  final int artisanNegotiationRoundsUsed;
  final int clientNegotiationRoundsUsed;
  final DateTime? negotiationStartedAt;
  final DateTime? negotiationUpdatedAt;
  final DateTime? negotiationAgreedAt;
  final DateTime? negotiationDeclinedAt;
  final bool negotiatedOverride;
  final ArtisanBookingStatus status;
  final DateTime? acceptedAt;
  final DateTime? paidAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? completionNotes;
  final List<String>? completionImages;
  final DateTime? completionMarkedByArtisanAt;
  final DateTime? completionConfirmedByClientAt;
  final DateTime? completionConfirmationDeadlineAt;
  final DateTime? completionDisputedAt;
  final String? completionDisputeReason;
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
    this.negotiatedAmount,
    this.negotiationCondition,
    this.negotiationStatus = 'none',
    this.negotiationLastOfferBy,
    this.artisanNegotiationRoundsUsed = 0,
    this.clientNegotiationRoundsUsed = 0,
    this.negotiationStartedAt,
    this.negotiationUpdatedAt,
    this.negotiationAgreedAt,
    this.negotiationDeclinedAt,
    this.negotiatedOverride = false,
    required this.status,
    this.acceptedAt,
    this.paidAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.completionNotes,
    this.completionImages,
    this.completionMarkedByArtisanAt,
    this.completionConfirmedByClientAt,
    this.completionConfirmationDeadlineAt,
    this.completionDisputedAt,
    this.completionDisputeReason,
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
    double? negotiatedAmount,
    String? negotiationCondition,
    String? negotiationStatus,
    String? negotiationLastOfferBy,
    int? artisanNegotiationRoundsUsed,
    int? clientNegotiationRoundsUsed,
    DateTime? negotiationStartedAt,
    DateTime? negotiationUpdatedAt,
    DateTime? negotiationAgreedAt,
    DateTime? negotiationDeclinedAt,
    bool? negotiatedOverride,
    DateTime? acceptedAt,
    DateTime? paidAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? rejectionReason,
    String? completionNotes,
    List<String>? completionImages,
    DateTime? completionMarkedByArtisanAt,
    DateTime? completionConfirmedByClientAt,
    DateTime? completionConfirmationDeadlineAt,
    DateTime? completionDisputedAt,
    String? completionDisputeReason,
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
      negotiatedAmount: negotiatedAmount ?? this.negotiatedAmount,
      negotiationCondition: negotiationCondition ?? this.negotiationCondition,
      negotiationStatus: negotiationStatus ?? this.negotiationStatus,
      negotiationLastOfferBy:
          negotiationLastOfferBy ?? this.negotiationLastOfferBy,
      artisanNegotiationRoundsUsed:
          artisanNegotiationRoundsUsed ?? this.artisanNegotiationRoundsUsed,
      clientNegotiationRoundsUsed:
          clientNegotiationRoundsUsed ?? this.clientNegotiationRoundsUsed,
      negotiationStartedAt: negotiationStartedAt ?? this.negotiationStartedAt,
      negotiationUpdatedAt: negotiationUpdatedAt ?? this.negotiationUpdatedAt,
      negotiationAgreedAt: negotiationAgreedAt ?? this.negotiationAgreedAt,
      negotiationDeclinedAt:
          negotiationDeclinedAt ?? this.negotiationDeclinedAt,
      negotiatedOverride: negotiatedOverride ?? this.negotiatedOverride,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      paidAt: paidAt ?? this.paidAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completionNotes: completionNotes ?? this.completionNotes,
      completionImages: completionImages ?? this.completionImages,
      completionMarkedByArtisanAt:
          completionMarkedByArtisanAt ?? this.completionMarkedByArtisanAt,
      completionConfirmedByClientAt:
          completionConfirmedByClientAt ?? this.completionConfirmedByClientAt,
      completionConfirmationDeadlineAt:
          completionConfirmationDeadlineAt ??
          this.completionConfirmationDeadlineAt,
      completionDisputedAt: completionDisputedAt ?? this.completionDisputedAt,
      completionDisputeReason:
          completionDisputeReason ?? this.completionDisputeReason,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
