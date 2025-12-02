import '../domain/models/onboarding_content.dart';

class OnboardingData {
  static const List<OnboardingContent> artisanOnboarding = [
    OnboardingContent(
      title: 'Get Jobs That Fit Your Skills',
      description: 'Join other verified artisans getting steady work from real customers near them.',
      imagePath: 'assets/images/regular.jpg',
    ),
    OnboardingContent(
      title: 'Choose When and How You Work',
      description: 'Set your availability, pick the jobs wey you fit do, and manage your time well.',
      imagePath: 'assets/images/regular.jpg',
    ),
    OnboardingContent(
      title: 'Earn Fast, No Stories',
      description: 'Finish the job, get paid to your wallet quick. Everything clear and simple.',
      imagePath: 'assets/images/regular.jpg',
    ),
  ];

  static const List<OnboardingContent> clientOnboarding = [
    OnboardingContent(
      title: 'Find Trusted Artisans Nearby',
      description: 'Hire reliable plumbers, electricians, and more around you. Verified, rated, and ready to work.',
      imagePath: 'assets/images/onboarding_map.png',
    ),
    OnboardingContent(
      title: 'Book Services Your Way',
      description: 'Set your budget, choose time wey work for you, and get matched with the right person.',
      imagePath: 'assets/images/regular.jpg',
    ),
    OnboardingContent(
      title: 'Pay Securely, No Wahala',
      description: 'Your money dey safe until the job complete. Easy and stress-free.',
      imagePath: 'assets/images/regular.jpg',
    ),
  ];
}
