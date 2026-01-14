import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import 'package:workchop/features/bookings/data/mock_booking_data.dart';
import 'package:workchop/features/bookings/presentation/widgets/completed_booking_card.dart';
import 'package:workchop/features/bookings/presentation/widgets/ongoing_booking_card.dart';
import 'package:workchop/features/bookings/presentation/widgets/request_booking_card.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _mainTabIndex = 0; // 0: Active, 1: History
  int _filterIndex = 0;

  final List<String> _filters = ['All', 'Requested', 'Ongoing', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: BodyText(
          'Bookings',
          size: BodySize.large,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Tab Switcher
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    _buildMainTab('Active', 0),
                    _buildMainTab('History', 1),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Secondary Filter Chips
            SizedBox(
              height: 32.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  return _buildFilterChip(_filters[index], index);
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Bookings List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: _mainTabIndex == 0 ? _buildActiveList() : _buildHistoryList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTab(String label, int index) {
    bool isActive = _mainTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _mainTabIndex = index;
          _filterIndex = 0;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: BodyText(
            label,
            size: BodySize.medium,
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    bool isActive = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: BodyText(
          label,
          size: BodySize.small,
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  List<Widget> _buildActiveList() {
    final activeBookings = MockBookingData.clientBookings
        .where((b) => b.status == 'ongoing' || b.status == 'requested')
        .toList();

    return activeBookings.map((booking) {
      if (booking.status == 'ongoing') {
        return OngoingBookingCard(booking: booking);
      } else {
        return RequestBookingCard(booking: booking);
      }
    }).toList();
  }

  List<Widget> _buildHistoryList() {
    final historyBookings = MockBookingData.clientBookings
        .where((b) => b.status == 'completed' || b.status == 'cancelled')
        .toList();

    return historyBookings.map((booking) {
      return CompletedBookingCard(booking: booking);
    }).toList();
  }
}
