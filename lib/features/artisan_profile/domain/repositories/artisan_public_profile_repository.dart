import '../models/artisan_public_profile.dart';
import '../models/portfolio_item.dart';
import '../models/reviews_data.dart';

/// Abstract repository interface for public artisan profile operations
abstract class ArtisanPublicProfileRepository {
  /// Get public profile for an artisan
  Future<ArtisanPublicProfile> getPublicProfile(String artisanId);

  /// Get portfolio items for an artisan
  Future<List<PortfolioItem>> getArtisanPortfolio(String artisanId);

  /// Get reviews and rating distribution for an artisan
  Future<ReviewsData> getArtisanReviews(String artisanId, {int page = 1});
}
