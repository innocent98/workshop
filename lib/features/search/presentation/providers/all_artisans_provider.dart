import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../../../core/providers/location_provider.dart';
import '../../data/models/search_request.dart';
import 'nearby_artisans_provider.dart';

/// Auto-disposed so an empty or failed result is never cached: leaving and
/// re-entering the screen fetches again.
final allArtisansProvider = FutureProvider.autoDispose<List<Artisan>>((
  ref,
) async {
  final locationData = await ref.watch(locationProvider.future);
  final repository = ref.watch(searchRepositoryProvider);

  final request = SearchArtisansRequest(
    latitude: locationData.latitude,
    longitude: locationData.longitude,
    radiusKm: 100.0,
    verifiedOnly: false,
    limit: 300,
  );

  final artisans = await repository.searchArtisans(request);

  artisans.sort((a, b) {
    if (a.distanceKm == null && b.distanceKm == null) return 0;
    if (a.distanceKm == null) return 1;
    if (b.distanceKm == null) return -1;
    return a.distanceKm!.compareTo(b.distanceKm!);
  });

  return artisans;
});
