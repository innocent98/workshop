import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../data/models/search_request.dart';
import 'nearby_artisans_provider.dart';

class SearchArtisansQueryInput {
  final String query;
  final double? latitude;
  final double? longitude;

  const SearchArtisansQueryInput({
    required this.query,
    this.latitude,
    this.longitude,
  });

  @override
  bool operator ==(Object other) {
    return other is SearchArtisansQueryInput &&
        other.query == query &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(query, latitude, longitude);
}

final searchArtisansByQueryProvider =
    FutureProvider.family<List<Artisan>, SearchArtisansQueryInput>((
      ref,
      input,
    ) async {
      final query = input.query.trim().toLowerCase();
      final locationData = await ref.watch(locationProvider.future);
      final latitude = input.latitude ?? locationData.latitude;
      final longitude = input.longitude ?? locationData.longitude;
      final services = await ref.watch(servicesProvider.future);
      final repository = ref.watch(searchRepositoryProvider);

      final matchedServiceIds = query.isEmpty
          ? <String>[]
          : services
                .where(
                  (service) =>
                      service.name.toLowerCase().contains(query) ||
                      (service.categoryName?.toLowerCase().contains(query) ??
                          false),
                )
                .map((service) => service.id)
                .toList();

      final request = SearchArtisansRequest(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 100.0,
        verifiedOnly: false,
        serviceIds: matchedServiceIds.isEmpty ? null : matchedServiceIds,
      );

      var artisans = await repository.searchArtisans(request);

      // Client-side name-text matching fallback when no service name matched.
      if (query.isNotEmpty && matchedServiceIds.isEmpty) {
        artisans = artisans.where((artisan) {
          return artisan.name.toLowerCase().contains(query) ||
              artisan.service.toLowerCase().contains(query);
        }).toList();
      }

      artisans.sort((a, b) {
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

      return artisans;
    });
