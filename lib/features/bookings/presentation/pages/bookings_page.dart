import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/mock_bookings_data.dart';
import '../../domain/models/booking.dart';
import '../widgets/request_booking_card.dart';
import '../widgets/ongoing_booking_card.dart';
import '../widgets/completed_booking_card.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _currentTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  String _getSectionTitle() {
    switch (_currentTabIndex) {
      case 0:
        return 'Recent Requests';
      case 1:
        return 'Ongoing Jobs';
      case 2:
        return 'Ongoing Jobs';
      default:
        return 'Recent Requests';
    }
  }

  List<Booking> _getBookings() {
    switch (_currentTabIndex) {
      case 0:
        return MockBookingsData.requestBookings;
      case 1:
        return MockBookingsData.ongoingBookings;
      case 2:
        return MockBookingsData.completedBookings;
      default:
        return MockBookingsData.requestBookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _getBookings();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: HeaderText(
          'Your Bookings',
          size: HeaderSize.h4,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Requests',
                      isActive: _currentTabIndex == 0,
                      onTap: () => _onTabChanged(0),
                    ),
                    SizedBox(width: 4.w),
                    _TabButton(
                      label: 'Ongoing',
                      isActive: _currentTabIndex == 1,
                      onTap: () => _onTabChanged(1),
                    ),
                    SizedBox(width: 4.w),
                    _TabButton(
                      label: 'Completed',
                      isActive: _currentTabIndex == 2,
                      onTap: () => _onTabChanged(2),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacing),

            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyText(
                    _getSectionTitle(),
                    size: BodySize.medium,
                    fontWeight: FontWeight.w600,
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to see all
                    },
                    child: const BodyText(
                      'See all',
                      size: BodySize.small,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacing),

            // Bookings list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];

                  if (_currentTabIndex == 0) {
                    return RequestBookingCard(booking: booking);
                  } else if (_currentTabIndex == 1) {
                    return OngoingBookingCard(booking: booking);
                  } else {
                    return CompletedBookingCard(booking: booking);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Center(
            child: BodyText(
              label,
              size: BodySize.small,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
