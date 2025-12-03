class Artisan {
  final String id;
  final String name;
  final String service;
  final String imageUrl;
  final String avatarUrl;
  final double rating;
  final int jobsCompleted;
  final bool isVerified;

  const Artisan({
    required this.id,
    required this.name,
    required this.service,
    required this.imageUrl,
    required this.avatarUrl,
    this.rating = 0.0,
    this.jobsCompleted = 0,
    this.isVerified = false,
  });
}
