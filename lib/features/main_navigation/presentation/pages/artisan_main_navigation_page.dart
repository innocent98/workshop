import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/navigation/bottom_nav_bar.dart';
import '../../../artisan_home/presentation/pages/artisan_home_page.dart';
import '../../../bookings/presentation/pages/artisan_jobs_page.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../../support/presentation/pages/support_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../bookings/presentation/pages/earnings_page.dart';
import '../../../artisan_profile/presentation/providers/artisan_location_sync_provider.dart';

class ArtisanMainNavigationPage extends ConsumerStatefulWidget {
  final int initialIndex;

  const ArtisanMainNavigationPage({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ArtisanMainNavigationPage> createState() =>
      _ArtisanMainNavigationPageState();
}

class _ArtisanMainNavigationPageState
    extends ConsumerState<ArtisanMainNavigationPage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(artisanLocationSyncServiceProvider).syncOnAppLaunch();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Tabs live in an IndexedStack and are built once: refresh the job lists
    // (Home shows incoming requests, Jobs shows everything) on selection.
    if (index == 0 || index == 1) {
      ref.read(artisanBookingsProvider.notifier).refreshSilently();
    }
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
