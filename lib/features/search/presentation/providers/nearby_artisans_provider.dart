import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../../../core/providers/location_provider.dart';
import '../../data/models/search_request.dart';
import '../../data/repositories/search_repository_impl.dart';

final searchRepositoryProvider = Provider((ref) {
  return SearchRepositoryImpl();
});

final nearbyArtisansProvider = FutureProvider<List<Artisan>>((ref) async {
  final locationData = await ref.watch(locationProvider.future);
  final repository = ref.watch(searchRepositoryProvider);

  final request = SearchArtisansRequest(
    latitude: locationData.latitude,
    longitude: locationData.longitude,
    radiusKm: 10.0,
    verifiedOnly: true,
  );

  final artisans = await repository.searchArtisans(request);
  
  // Sort by distance (closest first)
  artisans.sort((a, b) {
    if (a.distanceKm == null && b.distanceKm == null) return 0;
    if (a.distanceKm == null) return 1;
    if (b.distanceKm == null) return -1;
    return a.distanceKm!.compareTo(b.distanceKm!);
  });

  return artisans;
});
