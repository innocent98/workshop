import '../../../search/data/models/artisan_search_model.dart';

class ArtisanServiceOption {
  final int? id;
  final String name;

  const ArtisanServiceOption({this.id, required this.name});
}

class Artisan {
  final String id;
  final String name;
  final String service;
  final String imageUrl;
  final String avatarUrl;
  final double rating;
  final int jobsCompleted;
  final bool isVerified;
  final double? distanceKm;
  final int? ratingsCount;
  final int? serviceId;
  final List<ArtisanServiceOption> offeredServices;

  const Artisan({
    required this.id,
    required this.name,
    required this.service,
    required this.imageUrl,
    required this.avatarUrl,
    this.rating = 0.0,
    this.jobsCompleted = 0,
    this.isVerified = false,
    this.distanceKm,
    this.ratingsCount,
    this.serviceId,
    this.offeredServices = const [],
  });

  /// Create Artisan from ArtisanSearchModel (API response)
  factory Artisan.fromSearchModel(ArtisanSearchModel model) {
    final fallbackName = '${model.firstName ?? ''} ${model.lastName ?? ''}'
        .trim();
    final displayName =
        (model.fullName != null && model.fullName!.trim().isNotEmpty)
        ? model.fullName!.trim()
        : fallbackName;

    final serviceName = model.services.isNotEmpty
        ? model.services.first.name
        : 'Artisan';

    // Use profile picture or first service image as avatar
    final avatar =
        model.profilePictureUrl ??
        (model.services.isNotEmpty ? model.services.first.imageUrl : null) ??
        'assets/images/regular.jpg';

    return Artisan(
      id: model.id,
      name: displayName.isNotEmpty ? displayName : 'Unknown',
      service: serviceName,
      imageUrl: model.portfolioUrl ?? avatar,
      avatarUrl: avatar,
      rating: model.averageRating ?? 0.0,
      jobsCompleted: model.totalJobsCompleted ?? 0,
      isVerified: model.isVerified,
      distanceKm: model.distanceKm,
      ratingsCount: model.ratingsCount,
      serviceId: model.services.isNotEmpty
          ? int.tryParse(model.services.first.id)
          : null,
      offeredServices: model.services
          .map(
            (service) => ArtisanServiceOption(
              id: int.tryParse(service.id),
              name: service.name,
            ),
          )
          .toList(),
    );
  }
}
