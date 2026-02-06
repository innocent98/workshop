class SearchArtisansRequest {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool verifiedOnly;
  final int? limit;
  final int? offset;
  final String? serviceId;

  const SearchArtisansRequest({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
    this.verifiedOnly = true,
    this.limit,
    this.offset,
    this.serviceId,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'verified_only': verifiedOnly,
    };

    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;
    if (serviceId != null) params['service_id'] = serviceId;

    return params;
  }
}
