class SearchArtisansRequest {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool verifiedOnly;
  final int? limit;
  final int? offset;
  final List<String>? serviceIds;

  const SearchArtisansRequest({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
    this.verifiedOnly = true,
    this.limit,
    this.offset,
    this.serviceIds,
  });

  Map<String, dynamic> toQueryParameters() {
    final clampedRadius = radiusKm.clamp(0.1, 100.0);

    final params = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': clampedRadius,
      'verified_only': verifiedOnly,
    };

    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;
    if (serviceIds != null && serviceIds!.isNotEmpty) {
      params['service_ids'] = serviceIds!.join(',');
    }

    return params;
  }
}
