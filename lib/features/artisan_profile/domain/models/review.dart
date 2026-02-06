class Review {
  final String id;
  final String reviewerName;
  final String reviewerAvatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final String? artisanResponse;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
    this.artisanResponse,
    required this.createdAt,
  });
}
