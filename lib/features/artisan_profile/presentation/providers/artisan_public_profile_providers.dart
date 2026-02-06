import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/artisan_public_profile.dart';
import '../../domain/models/portfolio_item.dart';
import '../../domain/models/reviews_data.dart';
import '../../domain/repositories/artisan_public_profile_repository.dart';
import '../../data/repositories/artisan_public_profile_repository_impl.dart';

/// Repository provider
final artisanPublicProfileRepositoryProvider = Provider<ArtisanPublicProfileRepository>((ref) {
  return ArtisanPublicProfileRepositoryImpl();
});

/// Provider for fetching public profile by artisan ID
final artisanPublicProfileProvider = FutureProvider.family<ArtisanPublicProfile, String>(
  (ref, artisanId) async {
    final repository = ref.watch(artisanPublicProfileRepositoryProvider);
    return await repository.getPublicProfile(artisanId);
  },
);

/// Provider for fetching portfolio by artisan ID
final artisanPortfolioProvider = FutureProvider.family<List<PortfolioItem>, String>(
  (ref, artisanId) async {
    final repository = ref.watch(artisanPublicProfileRepositoryProvider);
    return await repository.getArtisanPortfolio(artisanId);
  },
);

/// Provider for fetching reviews by artisan ID
final artisanReviewsProvider = FutureProvider.family<ReviewsData, String>(
  (ref, artisanId) async {
    final repository = ref.watch(artisanPublicProfileRepositoryProvider);
    return await repository.getArtisanReviews(artisanId);
  },
);
