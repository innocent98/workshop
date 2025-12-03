import 'package:flutter/material.dart';
import '../domain/models/service_category.dart';
import '../domain/models/artisan.dart';
import '../domain/models/blog_post.dart';

class MockData {
  static final List<ServiceCategory> serviceCategories = [
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
}
