import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/navigation/bottom_nav_bar.dart';
import '../../../client_home/presentation/pages/client_home_page.dart';
import '../../../bookings/presentation/pages/bookings_page.dart';
import '../../../support/presentation/pages/support_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../client_profile/presentation/providers/client_location_sync_provider.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ClientHomePage(), // Home tab content only
    const BookingsPage(), // Bookings tab
    const SupportPage(), // Support tab (placeholder)
    const ProfilePage(), // Profile tab
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientLocationSyncServiceProvider).syncOnAppLaunch();
    });
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
      ),
    );
  }
}
