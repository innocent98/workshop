import 'package:flutter/material.dart';
import '../../../../core/widgets/navigation/bottom_nav_bar.dart';
import '../../../artisan_home/presentation/pages/artisan_home_page.dart';
import '../../../bookings/presentation/pages/artisan_jobs_page.dart';
import '../../../support/presentation/pages/support_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../bookings/presentation/pages/earnings_page.dart';

class ArtisanMainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const ArtisanMainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<ArtisanMainNavigationPage> createState() =>
      _ArtisanMainNavigationPageState();
}

class _ArtisanMainNavigationPageState extends State<ArtisanMainNavigationPage> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const ArtisanHomePage(),
    const ArtisanJobsPage(), // Correctly using ArtisanJobsPage now
    const EarningsPage(),
    const SupportPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        isArtisan: true,
      ),
    );
  }
}
