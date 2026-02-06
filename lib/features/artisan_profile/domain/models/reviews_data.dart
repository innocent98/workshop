import 'review.dart';
import 'rating_distribution.dart';

/// Domain model for reviews data including rating distribution
class ReviewsData {
  final List<Review> reviews;
  final int total;
  final double averageRating;
  final RatingDistribution ratingDistribution;

  const ReviewsData({
    required this.reviews,
    required this.total,
    required this.averageRating,
    required this.ratingDistribution,
  });

  factory ReviewsData.empty() {
    return ReviewsData(
      reviews: const [],
      total: 0,
      averageRating: 0.0,
      ratingDistribution: RatingDistribution.empty(),
    );
  }
}
