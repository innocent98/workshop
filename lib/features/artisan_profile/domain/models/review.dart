class Review {
  final String id;

  /// Author's user id. Used to hide "Report" on the viewer's own review.
  final String? customerId;
  final String reviewerName;
  final String reviewerAvatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final String? artisanResponse;
  final DateTime createdAt;

  const Review({
    required this.id,
    this.customerId,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
    this.artisanResponse,
    required this.createdAt,
  });
}
