import '../../domain/models/artisan_booking.dart';

class ArtisanBookingResponseModel {
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

  const ArtisanBookingResponseModel({
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

  factory ArtisanBookingResponseModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value.toString());
    }

    return ArtisanBookingResponseModel(
      id: json['id'] as int,
      bookingReference: json['booking_reference'] as String,
      customerId: json['customer_id'].toString(),
      artisanId: json['artisan_id'].toString(),
      serviceId: json['service_id'] as int,
      customerName: json['customer_name'] as String?,
      customerProfilePictureUrl:
          json['customer_profile_picture_url'] as String?,
      customerPhoneNumber: json['customer_phone_number'] as String?,
      artisanName: json['artisan_name'] as String?,
      artisanProfilePictureUrl: json['artisan_profile_picture_url'] as String?,
      artisanPhoneNumber: json['artisan_phone_number'] as String?,
      serviceName: json['service_name'] as String?,
      serviceImage: json['service_image'] as String?,
      jobDescription: json['job_description'] as String?,
      jobDate: DateTime.parse(json['job_date'] as String),
      jobAddress: json['job_address'] as String,
      jobLatitude: parseDouble(json['job_latitude']),
      jobLongitude: parseDouble(json['job_longitude']),
      budgetMin: parseDouble(json['budget_min']) ?? 0,
      budgetMax: parseDouble(json['budget_max']) ?? 0,
      agreedAmount: parseDouble(json['agreed_amount']),
      negotiatedAmount: parseDouble(json['negotiated_amount']),
      negotiationCondition: json['negotiation_condition'] as String?,
      negotiationStatus: (json['negotiation_status'] as String?) ?? 'none',
      negotiationLastOfferBy: json['negotiation_last_offer_by'] as String?,
      artisanNegotiationRoundsUsed:
          (json['artisan_negotiation_rounds_used'] as num?)?.toInt() ?? 0,
      clientNegotiationRoundsUsed:
          (json['client_negotiation_rounds_used'] as num?)?.toInt() ?? 0,
      negotiationStartedAt: json['negotiation_started_at'] != null
          ? DateTime.parse(json['negotiation_started_at'] as String)
          : null,
      negotiationUpdatedAt: json['negotiation_updated_at'] != null
          ? DateTime.parse(json['negotiation_updated_at'] as String)
          : null,
      negotiationAgreedAt: json['negotiation_agreed_at'] != null
          ? DateTime.parse(json['negotiation_agreed_at'] as String)
          : null,
      negotiationDeclinedAt: json['negotiation_declined_at'] != null
          ? DateTime.parse(json['negotiation_declined_at'] as String)
          : null,
      negotiatedOverride: json['negotiated_override'] == true,
      status: artisanBookingStatusFromApi((json['status'] as String?) ?? ''),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      completionNotes: json['completion_notes'] as String?,
      completionImages: (json['completion_images'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      completionMarkedByArtisanAt:
          json['completion_marked_by_artisan_at'] != null
          ? DateTime.parse(json['completion_marked_by_artisan_at'] as String)
          : null,
      completionConfirmedByClientAt:
          json['completion_confirmed_by_client_at'] != null
          ? DateTime.parse(json['completion_confirmed_by_client_at'] as String)
          : null,
      completionConfirmationDeadlineAt:
          json['completion_confirmation_deadline_at'] != null
          ? DateTime.parse(
              json['completion_confirmation_deadline_at'] as String,
            )
          : null,
      completionDisputedAt: json['completion_disputed_at'] != null
          ? DateTime.parse(json['completion_disputed_at'] as String)
          : null,
      completionDisputeReason: json['completion_dispute_reason'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ArtisanBooking toDomain() {
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
      agreedAmount: agreedAmount,
      negotiatedAmount: negotiatedAmount,
      negotiationCondition: negotiationCondition,
      negotiationStatus: negotiationStatus,
      negotiationLastOfferBy: negotiationLastOfferBy,
      artisanNegotiationRoundsUsed: artisanNegotiationRoundsUsed,
      clientNegotiationRoundsUsed: clientNegotiationRoundsUsed,
      negotiationStartedAt: negotiationStartedAt,
      negotiationUpdatedAt: negotiationUpdatedAt,
      negotiationAgreedAt: negotiationAgreedAt,
      negotiationDeclinedAt: negotiationDeclinedAt,
      negotiatedOverride: negotiatedOverride,
      status: status,
      acceptedAt: acceptedAt,
      paidAt: paidAt,
      startedAt: startedAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      completionNotes: completionNotes,
      completionImages: completionImages,
      completionMarkedByArtisanAt: completionMarkedByArtisanAt,
      completionConfirmedByClientAt: completionConfirmedByClientAt,
      completionConfirmationDeadlineAt: completionConfirmationDeadlineAt,
      completionDisputedAt: completionDisputedAt,
      completionDisputeReason: completionDisputeReason,
      cancellationReason: cancellationReason,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ArtisanBookingListResponseModel {
  final List<ArtisanBookingResponseModel> bookings;
  final int total;
  final int page;
  final int pageSize;

  const ArtisanBookingListResponseModel({
    required this.bookings,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ArtisanBookingListResponseModel.fromJson(Map<String, dynamic> json) {
    final bookingsJson = (json['bookings'] as List<dynamic>? ?? const []);

    return ArtisanBookingListResponseModel(
      bookings: bookingsJson
          .map(
            (item) => ArtisanBookingResponseModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );
  }
}
