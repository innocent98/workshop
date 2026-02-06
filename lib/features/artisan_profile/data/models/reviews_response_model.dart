import '../../domain/models/review.dart';
import '../../domain/models/reviews_data.dart';
import '../../domain/models/rating_distribution.dart';

/// Response model for individual review from API
class ReviewResponseModel {
  final String id;
  final double rating;
  final String? reviewText;
  final String customerName;
  final String? customerProfilePicture;
  final String? artisanResponse;
  final String createdAt;

  const ReviewResponseModel({
    required this.id,
    required this.rating,
    this.reviewText,
    required this.customerName,
    this.customerProfilePicture,
    this.artisanResponse,
    required this.createdAt,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      id: json['id'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewText: json['review_text'] as String?,
      customerName: json['customer_name'] as String,
      customerProfilePicture: json['customer_profile_picture'] as String?,
      artisanResponse: json['artisan_response'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Review toDomain() {
    return Review(
      id: id,
      reviewerName: customerName,
      reviewerAvatarUrl: customerProfilePicture ?? '',
      rating: rating,
      comment: reviewText ?? '',
      date: DateTime.tryParse(createdAt) ?? DateTime.now(),
      artisanResponse: artisanResponse,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

/// Response model for rating distribution from API
class RatingDistributionResponseModel {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;

  const RatingDistributionResponseModel({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.fourStar,
    required this.fiveStar,
  });

  factory RatingDistributionResponseModel.fromJson(Map<String, dynamic> json) {
    return RatingDistributionResponseModel(
      oneStar: json['1'] as int? ?? 0,
      twoStar: json['2'] as int? ?? 0,
      threeStar: json['3'] as int? ?? 0,
      fourStar: json['4'] as int? ?? 0,
      fiveStar: json['5'] as int? ?? 0,
    );
  }

  RatingDistribution toDomain() {
    return RatingDistribution(
      oneStar: oneStar,
      twoStar: twoStar,
      threeStar: threeStar,
      fourStar: fourStar,
      fiveStar: fiveStar,
    );
  }
}

/// Response model for reviews data from API
class ReviewsResponseModel {
  final List<ReviewResponseModel> reviews;
  final int total;
  final double averageRating;
  final RatingDistributionResponseModel ratingDistribution;

  const ReviewsResponseModel({
    required this.reviews,
    required this.total,
    required this.averageRating,
    required this.ratingDistribution,
  });

  factory ReviewsResponseModel.fromJson(Map<String, dynamic> json) {
    final reviewsList = json['reviews'] as List? ?? [];
    return ReviewsResponseModel(
      reviews: reviewsList
          .map((item) => ReviewResponseModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingDistribution: RatingDistributionResponseModel.fromJson(
        json['rating_distribution'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  ReviewsData toDomain() {
    return ReviewsData(
      reviews: reviews.map((review) => review.toDomain()).toList(),
      total: total,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution.toDomain(),
    );
  }
}
