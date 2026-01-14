import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workchop/features/artisan_home/data/mock_artisan_data.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../widgets/artisan_job_card.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _mainTabIndex = 0; // 0: Upcoming, 1: History
  int _filterIndex = 0;

  final List<String> _upcomingFilters = ['All', 'Pending', 'Accepted', 'Today'];
  final List<String> _historyFilters = ['All', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: HeaderText(
          'Your Jobs',
          size: HeaderSize.h4,
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
                    _buildMainTab('Upcoming', 0),
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
                itemCount: _mainTabIndex == 0 ? _upcomingFilters.length : _historyFilters.length,
                itemBuilder: (context, index) {
                  final filters = _mainTabIndex == 0 ? _upcomingFilters : _historyFilters;
                  return _buildFilterChip(filters[index], index);
                },
              ),
            ),
            SizedBox(height: 16.h),

            // History Summary Header
            if (_mainTabIndex == 1) _buildHistorySummary(),

            // Jobs List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: _mainTabIndex == 0 ? _buildUpcomingList() : _buildHistoryList(),
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

  Widget _buildHistorySummary() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BodyText('Total Earned: ', size: BodySize.medium, fontWeight: FontWeight.w500),
              BodyText('₦140,000', size: BodySize.medium, color: const Color(0xFFE2725B), fontWeight: FontWeight.w500),
            ],
          ),
          BodyText('From 2 jobs', size: BodySize.small, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  List<Widget> _buildUpcomingList() {
    final mockJob = MockArtisanData.jobRequests[0];
    return [
      ArtisanJobCard(
        status: ArtisanJobStatus.ongoing,
        serviceName: 'Leaking Faucet Repair',
        clientName: 'Idem Etop',
        clientAvatar: 'assets/images/regular.jpg',
        neededServices: const [
          'Door and Window Casing Installation',
          'Hardware Installation (Hinges, Drawer Slides, Locks)',
          'Advanced Wood Joinery',
        ],
        onActionPressed: () => context.push(AppRoutes.jobDetail, extra: mockJob),
        onCardTap: () => context.push(AppRoutes.jobDetail, extra: mockJob),
      ),
      ArtisanJobCard(
        status: ArtisanJobStatus.next,
        serviceName: 'Leaking Faucet Repair',
        clientName: 'Idem Etop',
        clientAvatar: 'assets/images/regular.jpg',
        neededServices: const [
          'Door and Window Casing Installation',
          'Hardware Installation (Hinges, Drawer Slides, Locks)',
          'Advanced Wood Joinery',
        ],
        onActionPressed: () => context.push(AppRoutes.jobDetail, extra: mockJob),
        onCardTap: () => context.push(AppRoutes.jobDetail, extra: mockJob),
      ),
      ArtisanJobCard(
        status: ArtisanJobStatus.pending,
        serviceName: 'Plumbing Repair',
        clientName: 'Yannic Bazeel',
        clientAvatar: 'assets/images/regular.jpg',
        price: 'N5k - N7k',
        neededServices: const [
          'Door and Window Casing Installation',
          'Hardware Installation (Hinges, Drawer Slides, Locks)',
          'Advanced Wood Joinery',
        ],
        onActionPressed: () => context.push(AppRoutes.jobDetail, extra: mockJob),
        onCardTap: () => context.push(AppRoutes.jobDetail, extra: mockJob),
      ),
    ];
  }

  List<Widget> _buildHistoryList() {
    final mockJob = MockArtisanData.jobRequests[0];
    return [
      ArtisanJobCard(
        status: ArtisanJobStatus.completed,
        serviceName: 'Plumbing Repair',
        clientName: 'Yannic Bazeel',
        clientAvatar: 'assets/images/regular.jpg',
        price: '₦ 7,000',
        timeInfo: 'Saturday, 27 Nov, 2025 • 07:25 AM',
        neededServices: const [
          'Door and Window Casing Installation',
          'Hardware Installation (Hinges, Drawer Slides, Locks)',
          'Advanced Wood Joinery',
        ],
        onActionPressed: () {},
        onCardTap: () => context.push(AppRoutes.jobDetail, extra: mockJob),
      ),
      ArtisanJobCard(
        status: ArtisanJobStatus.cancelled,
        serviceName: 'Plumbing Repair',
        clientName: 'Yannic Bazeel',
        clientAvatar: 'assets/images/regular.jpg',
        price: 'N7k',
        timeInfo: 'Saturday, 27 Nov, 2025 • 07:25 AM',
        neededServices: const [
          'Door and Window Casing Installation',
          'Hardware Installation (Hinges, Drawer Slides, Locks)',
          'Advanced Wood Joinery',
        ],
        onActionPressed: () {},
        onCardTap: () => context.push(AppRoutes.jobDetail, extra: mockJob),
      ),
    ];
  }
}
