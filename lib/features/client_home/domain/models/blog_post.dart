class BlogPost {
  final String id;
  final String title;
  final int readTimeMinutes;
  final String? imageUrl;

  const BlogPost({
    required this.id,
    required this.title,
    required this.readTimeMinutes,
    this.imageUrl,
  });
}
