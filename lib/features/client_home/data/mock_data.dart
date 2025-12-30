import 'package:flutter/material.dart';
import '../domain/models/service_category.dart';
import '../domain/models/artisan.dart';
import '../domain/models/blog_post.dart';
import '../../search_result/domain/models/store.dart';

class MockData {
  // Featured service categories for home page (first 6)
  static final List<ServiceCategory> featuredServiceCategories = [
    const ServiceCategory(
      id: '1',
      name: 'Plumbing',
      icon: Icons.plumbing_outlined,
    ),
    const ServiceCategory(
      id: '2',
      name: 'AC Repair',
      icon: Icons.ac_unit_outlined,
    ),
    const ServiceCategory(
      id: '3',
      name: 'Electrician',
      icon: Icons.electrical_services_outlined,
    ),
    const ServiceCategory(
      id: '4',
      name: 'Carpentry',
      icon: Icons.carpenter_outlined,
    ),
    const ServiceCategory(
      id: '5',
      name: 'Painting',
      icon: Icons.format_paint_outlined,
    ),
    const ServiceCategory(
      id: '6',
      name: 'Cleaning',
      icon: Icons.cleaning_services_outlined,
    ),
  ];

  // All service categories
  static final List<ServiceCategory> allServiceCategories = [
    const ServiceCategory(
      id: '1',
      name: 'Hairdressers',
      icon: Icons.content_cut_outlined,
    ),
    const ServiceCategory(
      id: '2',
      name: 'Beauticians',
      icon: Icons.face_outlined,
    ),
    const ServiceCategory(
      id: '3',
      name: 'Makeup Artists',
      icon: Icons.brush_outlined,
    ),
    const ServiceCategory(
      id: '4',
      name: 'Plumbers',
      icon: Icons.plumbing_outlined,
    ),
    const ServiceCategory(
      id: '5',
      name: 'Painters',
      icon: Icons.format_paint_outlined,
    ),
    const ServiceCategory(
      id: '6',
      name: 'Cleaners',
      icon: Icons.cleaning_services_outlined,
    ),
    const ServiceCategory(
      id: '7',
      name: 'Car Rewirers',
      icon: Icons.electrical_services_outlined,
    ),
    const ServiceCategory(
      id: '8',
      name: 'Photographers',
      icon: Icons.camera_alt_outlined,
    ),
    const ServiceCategory(
      id: '9',
      name: 'Car Mechanics',
      icon: Icons.build_outlined,
    ),
    const ServiceCategory(
      id: '10',
      name: 'Dispatch Rider',
      icon: Icons.delivery_dining_outlined,
    ),
  ];

  static final List<Artisan> nearbyArtisans = [
    const Artisan(
      id: '1',
      name: 'Nancy Michael',
      service: 'Electrician',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.8,
      jobsCompleted: 127,
      isVerified: true,
    ),
    const Artisan(
      id: '2',
      name: 'Oluwasegun Th',
      service: 'AC Repair',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      rating: 4.6,
      jobsCompleted: 89,
      isVerified: true,
    ),
  ];

  static final List<BlogPost> blogPosts = [
    const BlogPost(
      id: '1',
      title: 'Easy Ways to Clean your Stained Iron',
      readTimeMinutes: 3,
    ),
    const BlogPost(
      id: '2',
      title: 'Networking yo',
      readTimeMinutes: 3,
    ),
  ];

  static final List<Store> nearbyStores = [
    const Store(
      id: '1',
      name: 'Obigod Tools & Hardwares',
      ownerName: 'Moses Tom',
      description: 'A leading supplier of industrial power tools, hardware, and commercial equipment, based in Lagos and stocking trusted brands like Bosch and...',
      imageUrl: 'assets/images/regular.jpg',
      avatarUrl: 'assets/images/regular.jpg',
      distance: '2.5 km',
      rating: 4.7,
      salesCount: 543,
    ),
  ];
}
