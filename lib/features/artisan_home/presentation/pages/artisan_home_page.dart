import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/mock_artisan_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/job_request_card.dart';
import '../widgets/ongoing_job_card.dart';
import '../widgets/store_card.dart';
import '../../../../core/widgets/forms/custom_switch.dart';

class ArtisanHomePage extends ConsumerStatefulWidget {
  const ArtisanHomePage({super.key});

  @override
  ConsumerState<ArtisanHomePage> createState() => _ArtisanHomePageState();
}

class _ArtisanHomePageState extends ConsumerState<ArtisanHomePage> {
  bool _isAvailable = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Toggle Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    _buildHeader(user?.name ?? 'Ethan'),
                    SizedBox(height: 12.h),
                    _buildAvailabilityToggle(),
                  ],
                ),
              ),

              // Stats Cards Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildStatsCards(),
              ),

              SizedBox(height: 16.h),

              // Ongoing Job Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: const OngoingJobCard(),
              ),

              SizedBox(height: 24.h),

              // Requests Section
              _buildSectionTitle('Requests', hasNew: true, onSeeAll: () {}),
              SizedBox(height: 10.h),
              SizedBox(
                height: 280.h, // Reduced height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: MockArtisanData.jobRequests.length,
                  itemBuilder: (context, index) {
                    return JobRequestCard(
                      job: MockArtisanData.jobRequests[index],
                      onAccept: () {},
                      onDecline: () {},
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),

              // Nearby stores Section
              _buildSectionTitle('Nearby stores', onSeeAll: () {}),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: const [
                    StoreCard(
                      name: 'Obigod Tools & Hardwares',
                      proprietor: 'Moses Tom',
                      description: 'A leading supplier of industrial power tools, hardware, and commercial equipment, based in Lagos and stocking trusted brands like Bosch and...',
                      rating: '4.5 (25 sales)',
                      distance: '3m away',
                      imagePath: 'assets/images/store1.jpg',
                    ),
                    StoreCard(
                      name: 'C. Woermann Nigeria',
                      proprietor: 'Chinaza Uche',
                      description: 'A long-established German-affiliated company (since 1968) that supplies high-quality technical equipment, machinery, and after-sales service to N...',
                      rating: '4.5 (25 sales)',
                      distance: '3m away',
                      imagePath: 'assets/images/store2.jpg',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundImage: const AssetImage('assets/images/regular.jpg'),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Row(
            children: [
              BodyText('Welcome, ', size: BodySize.large),
              BodyText(name, size: BodySize.medium, fontWeight: FontWeight.w500),
            ],
          ),
        ),
        Icon(Icons.notifications_outlined, size: 22.r, color: AppColors.textPrimary),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText(
              _isAvailable ? "You're online" : "You're offline",
              size: BodySize.large,
              fontWeight: FontWeight.w500,
            ),
            BodyText(
              _isAvailable ? 'Available for Jobs' : 'Unavailable for Jobs',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        CustomSwitch(
          value: _isAvailable,
          onChanged: (value) => setState(() => _isAvailable = value),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: const StatCard(
            label: 'Todays Earnings',
            value: '₦ 4,800',
            subText: '+12% vs yest.',
            valueColor: AppColors.primary,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: const StatCard(
            label: 'Completed Jobs',
            value: '34',
            valueColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool hasNew = false, required VoidCallback onSeeAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          BodyText(title, size: BodySize.large, fontWeight: FontWeight.normal),
          if (hasNew) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFBCCBCB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: BodyText('2 new', size: BodySize.small, color: AppColors.primary, fontWeight: FontWeight.normal),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: BodyText('See all', size: BodySize.small, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
