class UpdateAvailabilityRequestModel {
  final String availabilityStatus;

  const UpdateAvailabilityRequestModel({
    required this.availabilityStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'availability_status': availabilityStatus,
    };
  }
}
