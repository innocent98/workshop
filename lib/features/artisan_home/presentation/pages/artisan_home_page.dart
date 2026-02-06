import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/mock_artisan_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/job_request_card.dart';
import '../widgets/ongoing_job_card.dart';
import '../widgets/store_card.dart';
import '../../../../core/widgets/forms/custom_switch.dart';
import '../../../artisan_profile/presentation/providers/artisan_profile_provider.dart';
import '../../../artisan_profile/presentation/providers/artisan_wallet_provider.dart';
import '../../../artisan_profile/domain/models/artisan_profile.dart';
import '../../../artisan_profile/domain/models/wallet_balance.dart';

class ArtisanHomePage extends ConsumerStatefulWidget {
  const ArtisanHomePage({super.key});

  @override
  ConsumerState<ArtisanHomePage> createState() => _ArtisanHomePageState();
}

class _ArtisanHomePageState extends ConsumerState<ArtisanHomePage> {
  bool _isUpdatingAvailability = false;

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      data: (user) => _buildContent(user),
      loading: () => _buildLoadingSkeleton(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildContent(User? user) {
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
                    _buildHeader(user?.fullName ?? 'Guest', user?.profilePictureUrl),
                    SizedBox(height: 12.h),
                    _buildAvailabilityToggle(),
                  ],
                ),
              ),

              // Stats Cards Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildStatsCardsSection(),
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

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    _buildHeaderSkeleton(),
                    SizedBox(height: 12.h),
                    _buildAvailabilityToggleSkeleton(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildStatsCardsSkeleton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            width: 150.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
              SizedBox(height: 16.h),
              BodyText(
                'Failed to load user data',
                size: BodySize.medium,
                color: AppColors.error,
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  ref.invalidate(authProvider);
                },
                child: const BodyText(
                  'Tap to retry',
                  size: BodySize.small,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String? profilePictureUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundImage: profilePictureUrl != null
              ? NetworkImage(profilePictureUrl) as ImageProvider
              : const AssetImage('assets/images/regular.jpg'),
          onBackgroundImageError: profilePictureUrl != null
              ? (exception, stackTrace) {}
              : null,
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

  Future<void> _handleAvailabilityToggle(bool isAvailable) async {
    setState(() => _isUpdatingAvailability = true);

    try {
      final notifier = ref.read(artisanProfileProvider.notifier);
      final newStatus = isAvailable
          ? AvailabilityStatus.available
          : AvailabilityStatus.offline;

      await notifier.updateAvailability(newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAvailable ? "You're now online" : "You're now offline"),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update availability';
        if (e is ApiException) {
          errorMessage = e.message;
        } else if (e is NetworkException) {
          errorMessage = e.message;
        } else if (e is UnauthorizedException) {
          errorMessage = e.message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAvailability = false);
      }
    }
  }

  Widget _buildAvailabilityToggle() {
    final profileAsync = ref.watch(artisanProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final isAvailable = profile.availabilityStatus == AvailabilityStatus.available;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(
                  isAvailable ? "You're online" : "You're offline",
                  size: BodySize.large,
                  fontWeight: FontWeight.w500,
                ),
                BodyText(
                  isAvailable ? 'Available for Jobs' : 'Unavailable for Jobs',
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            CustomSwitch(
              value: isAvailable,
              onChanged: _isUpdatingAvailability
                  ? (_) {} // No-op when updating
                  : (value) => _handleAvailabilityToggle(value),
            ),
          ],
        );
      },
      loading: () => _buildAvailabilityToggleSkeleton(),
      error: (error, stack) => _buildAvailabilityToggleError(),
    );
  }

  Widget _buildAvailabilityToggleSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: 150.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
        Container(
          width: 44.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggleError() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText(
              "Status unavailable",
              size: BodySize.large,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
            BodyText(
              'Tap to retry',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            ref.read(artisanProfileProvider.notifier).refresh();
          },
          child: Icon(
            Icons.refresh,
            color: AppColors.error,
            size: 24.r,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCardsSection() {
    final walletAsync = ref.watch(artisanWalletProvider);

    return walletAsync.when(
      data: (wallet) => _buildStatsCards(wallet),
      loading: () => _buildStatsCardsSkeleton(),
      error: (error, stack) => _buildStatsCardsError(),
    );
  }

  Widget _buildStatsCards(WalletBalance wallet) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Total Earnings',
            value: wallet.formattedEarnings,
            valueColor: AppColors.primary,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: StatCard(
            label: 'Completed Jobs',
            value: '${wallet.totalJobsCompleted}',
            valueColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCardsSkeleton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCardsError() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.invalidate(artisanWalletProvider);
            },
            child: const StatCard(
              label: 'Total Earnings',
              value: '--',
              subText: 'Tap to retry',
              valueColor: AppColors.error,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: const StatCard(
            label: 'Completed Jobs',
            value: '--',
            valueColor: AppColors.error,
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
