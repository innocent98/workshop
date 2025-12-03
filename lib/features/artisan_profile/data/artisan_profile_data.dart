import '../domain/models/portfolio_item.dart';
import '../domain/models/review.dart';

class ArtisanProfileData {
  static const String bio =
      'I am the specialist who perfects the visible details. I install decorative elements like trim, molding, doors, and custom built-ins to complete an interior with finesse.';

  static const List<String> skills = [
    'Miter and Cope Joint Fabrication',
    'Door and Window Casing Installation',
    'Hardware Installation (Hinges, Drawer Slides, Locks)',
    'Advanced Wood Joinery',
  ];

  static final List<PortfolioItem> portfolioItems = [
    const PortfolioItem(
      id: '1',
      title: 'Modern Living Room',
      imageUrl: 'assets/images/regular.jpg',
    ),
    const PortfolioItem(
      id: '2',
      title: 'Cozy Bedroom',
      imageUrl: 'assets/images/regular.jpg',
    ),
    const PortfolioItem(
      id: '3',
      title: 'Elegant Kitchen',
      imageUrl: 'assets/images/regular.jpg',
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: '1',
      reviewerName: 'Richard E.',
      reviewerAvatarUrl: 'assets/images/regular.jpg',
      rating: 4.0,
      comment:
          'I am absolutely thrilled with the custom built-in bookshelves they installed in my home office. From the initial consultation, I felt heard, they took the time to understand exactly the look and functionality I needed.',
      date: DateTime(2025, 11, 27, 7, 25),
    ),
    Review(
      id: '2',
      reviewerName: 'Abasifrek U.',
      reviewerAvatarUrl: 'assets/images/regular.jpg',
      rating: 4.0,
      comment: 'Great service and attention to detail!',
      date: DateTime(2025, 11, 15, 15, 20),
    ),
    Review(
      id: '3',
      reviewerName: 'Ngozi A.',
      reviewerAvatarUrl: 'assets/images/regular.jpg',
      rating: 4.0,
      comment:
          'I called Saviour for an emergency repair on a water-damaged door frame. I was amazed at how quickly he responded. He is highly skilled, fixed the structural issue with precision, and made sure the new trim matched the existing work perfectly. I would definitely use him again for any future woodworking needs.',
      date: DateTime(2025, 10, 15, 10, 13),
    ),
  ];

  static const Map<int, double> ratingDistribution = {
    5: 70,
    4: 20,
    3: 5,
    2: 3,
    1: 2,
  };
}
