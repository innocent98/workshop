import 'package:flutter/material.dart';
import '../../../../core/widgets/navigation/bottom_nav_bar.dart';
import '../../../client_home/presentation/pages/client_home_page.dart';
import '../../../bookings/presentation/pages/bookings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ClientHomePage(), // Home tab content only
    const BookingsPage(), // Bookings tab
    const SupportPage(), // Support tab (placeholder)
    const ProfilePage(), // Profile tab (placeholder)
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

// Temporary placeholder for Support page
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Support Page - Coming Soon'),
      ),
    );
  }
}

// Temporary placeholder for Profile page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page - Coming Soon'),
      ),
    );
  }
}
