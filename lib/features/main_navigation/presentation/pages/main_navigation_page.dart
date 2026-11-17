import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/navigation/bottom_nav_bar.dart';
import '../../../client_home/presentation/pages/client_home_page.dart';
import '../../../bookings/presentation/pages/bookings_page.dart';
import '../../../support/presentation/pages/support_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../client_profile/presentation/providers/client_location_sync_provider.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../../bookings/presentation/providers/payment_verification_provider.dart';
import '../../../search/presentation/providers/nearby_artisans_provider.dart';

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
      // Resume handling + recovery of a payment started before the app was
      // killed.
      ref.read(paymentVerificationProvider.notifier).attach();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _refreshTab(index);
  }

  /// Tabs live in an IndexedStack and are built once, so selecting one must
  /// itself refresh data that may have changed while it was hidden.
  void _refreshTab(int index) {
    switch (index) {
      case 0:
        // A cached empty/failed nearby list would otherwise stay until restart.
        final nearby = ref.read(nearbyArtisansProvider);
        if (!nearby.isLoading &&
            (nearby.hasError || (nearby.value?.isEmpty ?? false))) {
          ref.invalidate(nearbyArtisansProvider);
        }
      case 1:
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
      ),
    );
  }
}
