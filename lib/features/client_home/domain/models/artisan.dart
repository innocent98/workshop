import '../../../search/data/models/artisan_search_model.dart';

class ArtisanServiceOption {
  final int? id;
  final String name;

  const ArtisanServiceOption({this.id, required this.name});
}

class Artisan {
  final String id;
  final String name;
  final String? category;
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

  /// The service the user came looking for (set when they arrive from a
  /// search). The booking pages pre-select it instead of the first service.
  final ArtisanServiceOption? preferredService;

  const Artisan({
    required this.id,
    required this.name,
    this.category,
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
    this.preferredService,
  });

  /// Returns a copy that remembers which of this artisan's services matches
  /// [query] (a service name the user searched for or tapped). Unchanged when
  /// nothing matches, so booking falls back to the first service.
  Artisan withPreferredServiceFromQuery(String? query) {
    final needle = (query ?? '').trim().toLowerCase();
    if (needle.isEmpty) return this;
    ArtisanServiceOption? match;
    for (final option in offeredServices) {
      if (option.name.trim().toLowerCase() == needle) {
        match = option;
        break;
      }
    }
    match ??= () {
      for (final option in offeredServices) {
        final name = option.name.trim().toLowerCase();
        if (name.contains(needle) || needle.contains(name)) return option;
      }
      return null;
    }();
    if (match == null) return this;
    return Artisan(
      id: id,
      name: name,
      category: category,
      service: service,
      imageUrl: imageUrl,
      avatarUrl: avatarUrl,
      rating: rating,
      jobsCompleted: jobsCompleted,
      isVerified: isVerified,
      distanceKm: distanceKm,
      ratingsCount: ratingsCount,
      serviceId: serviceId,
      offeredServices: offeredServices,
      preferredService: match,
    );
  }

  /// Index in [options] of the service to pre-select: the preferred service
  /// when it is offered, otherwise the first one.
  int initialServiceIndex(List<ArtisanServiceOption> options) {
    final preferred = preferredService;
    if (preferred == null) return 0;
    final index = options.indexWhere(
      (o) =>
          (preferred.id != null && o.id == preferred.id) ||
          o.name.trim().toLowerCase() == preferred.name.trim().toLowerCase(),
    );
    return index < 0 ? 0 : index;
  }

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

    // Empty when the artisan has no photo; the UI shows an initials placeholder.
    final avatar = model.profilePictureUrl ?? '';
    final workImage =
        model.portfolioUrl ??
        (model.services.isNotEmpty ? model.services.first.imageUrl : null) ??
        avatar;

    return Artisan(
      id: model.id,
      name: displayName.isNotEmpty ? displayName : 'Unknown',
      category: model.categoryName,
      service: serviceName,
      imageUrl: workImage,
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
