import '../../client_home/domain/models/artisan.dart';
import '../domain/models/store.dart';

class SearchResultData {
  static final List<Artisan> artisans = [
    const Artisan(
      id: '1',
      name: 'Saviour Theophilus',
      service: 'Carpenter',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.5,
      jobsCompleted: 25,
      isVerified: true,
    ),
    const Artisan(
      id: '2',
      name: 'Amarachi Uzoh',
      service: 'Videographer',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.5,
      jobsCompleted: 25,
      isVerified: true,
    ),
    const Artisan(
      id: '3',
      name: 'Chukwuemeka Eze',
      service: 'Youtube video editor',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.5,
      jobsCompleted: 25,
      isVerified: true,
    ),
  ];

  static final List<Store> stores = [
    const Store(
      id: '1',
      name: 'Obigod Tools & Hardwares',
      ownerName: 'Moses Tom',
      description:
          'A leading supplier of industrial power tools, hardware, and commercial equipment, based in Lagos and stocking trusted brands like Bosch and...',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.5,
      salesCount: 25,
      distance: '3m away',
    ),
    const Store(
      id: '2',
      name: 'C. Woermann Nigeria',
      ownerName: 'Chinaza Uche',
      description:
          'A long-established German-affiliated company (since 1968) that supplies high-quality technical equipment, machinery, and after-sales service to N...',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.5,
      salesCount: 25,
      distance: '3m away',
    ),
  ];
}
