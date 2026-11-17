import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/routes/app_router.dart';
import '../widgets/stat_card.dart';
import '../widgets/job_request_card.dart';
import '../widgets/ongoing_job_card.dart';
import '../../../../core/widgets/forms/custom_switch.dart';
import '../../../artisan_profile/presentation/providers/artisan_profile_provider.dart';
import '../../../artisan_profile/presentation/providers/artisan_wallet_provider.dart';
import '../../../artisan_profile/domain/models/artisan_profile.dart';
import '../../../artisan_profile/domain/models/wallet_balance.dart';
import '../../../bookings/domain/models/artisan_booking.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../core/network/dio_error_mapper.dart';

class ArtisanHomePage extends ConsumerStatefulWidget {
  const ArtisanHomePage({super.key});

  @override
  ConsumerState<ArtisanHomePage> createState() => _ArtisanHomePageState();
}

class _ArtisanHomePageState extends ConsumerState<ArtisanHomePage> {
  bool _isUpdatingAvailability = false;

  Future<void> _refreshHome() async {
    await ref.read(artisanBookingsProvider.notifier).refresh();
    await ref.read(artisanProfileProvider.notifier).refresh();
    ref.invalidate(artisanWalletProvider);
    await ref.read(artisanWalletProvider.future);
    ref.invalidate(notificationsProvider);
    await ref.read(notificationsProvider.future);
  }

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
    final bookingsAsync = ref.watch(artisanBookingsProvider);
    final unreadCount = ref.watch(
      notificationsProvider.select((state) {
        return state.maybeWhen(
          data: (value) => value.unreadCount,
          orElse: () => 0,
        );
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Toggle Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(
                        user?.fullName ?? 'Guest',
                        user?.profilePictureUrl,
                        unreadCount,
                      ),
                      SizedBox(height: 12.h),
                      _buildAvailabilityToggle(),
                    ],
                  ),
                ),

                // Stats Cards Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCardsSection(),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: BodyText(
                          'A 10% Workchop service fee is deducted from each completed job.',
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Ongoing Job Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: bookingsAsync.when(
                    data: (bookings) {
                      ArtisanBooking? ongoing;
                      for (final booking in bookings) {
                        if (booking.status == ArtisanBookingStatus.inProgress) {
                          ongoing = booking;
                          break;
                        }
                      }
                      if (ongoing == null) {
                        for (final booking in bookings) {
                          if (booking.status == ArtisanBookingStatus.paid) {
                            ongoing = booking;
                            break;
                          }
                        }
                      }
                      if (ongoing == null) {
                        for (final booking in bookings) {
                          if (booking.status == ArtisanBookingStatus.accepted) {
                            ongoing = booking;
                            break;
                          }
                        }
                      }

                      if (ongoing == null) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h,
                            horizontal: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE5ECEC)),
                          ),
                          child: BodyText(
                            'No ongoing jobs right now',
                            size: BodySize.small,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }

                      final activeBooking = ongoing;
                      return OngoingJobCard(
                        booking: activeBooking,
                        onCall: () =>
                            _callPhone(activeBooking.customerPhoneNumber),
                      );
                    },
                    loading: () => Container(
                      height: 220.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    error: (error, stackTrace) => Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5ECEC)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: BodyText(
                              'Failed to load active job',
                              size: BodySize.small,
                              color: AppColors.error,
                            ),
                          ),
                          TextButton(
                            onPressed: () => ref
                                .read(artisanBookingsProvider.notifier)
                                .refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Requests Section
                _buildSectionTitle(
                  'Requests',
                  newCount: bookingsAsync.maybeWhen(
                    data: (bookings) => bookings
                        .where(
                          (booking) =>
                              booking.status == ArtisanBookingStatus.pending,
                        )
                        .length,
                    orElse: () => 0,
                  ),
                  onSeeAll: () =>
                      context.go('${AppRoutes.artisanHome}?tab=jobs'),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 250.h,
                  child: bookingsAsync.when(
                    data: (bookings) {
                      final pending = bookings
                          .where(
                            (booking) =>
                                booking.status == ArtisanBookingStatus.pending,
                          )
                          .toList();

                      if (pending.isEmpty) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          children: [
                            Container(
                              width: 0.85.sw,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F5),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: BodyText(
                                'No pending job requests',
                                size: BodySize.small,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: pending.length,
                        itemBuilder: (context, index) {
                          final booking = pending[index];
                          return JobRequestCard(
                            booking: booking,
                            onTap: () => context.push(
                              AppRoutes.jobDetail,
                              extra: booking,
                            ),
                            onAccept: () => _acceptBooking(booking),
                            onDecline: () => _rejectBooking(booking),
                            onCall: null,
                          );
                        },
                      );
                    },
                    loading: () => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        Container(
                          width: 0.85.sw,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ],
                    ),
                    error: (error, stackTrace) => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        Container(
                          width: 0.85.sw,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyText(
                                'Failed to load requests',
                                size: BodySize.small,
                                color: AppColors.error,
                              ),
                              SizedBox(height: 8.h),
                              TextButton(
                                onPressed: () => ref
                                    .read(artisanBookingsProvider.notifier)
                                    .refresh(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // How It Works Walkthrough
                _buildSectionTitle(
                  'How it works',
                  onSeeAll: () => _showHowItWorksModal(),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GestureDetector(
                    onTap: _showHowItWorksModal,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F5),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.play_lesson_outlined,
                              color: AppColors.primary,
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyText(
                                  'Booking flow walkthrough',
                                  size: BodySize.medium,
                                  fontWeight: FontWeight.w600,
                                ),
                                SizedBox(height: 2.h),
                                BodyText(
                                  'See the exact steps from request to completion.',
                                  size: BodySize.small,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 24.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
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

  Widget _buildHeader(String name, String? profilePictureUrl, int unreadCount) {
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
              BodyText(
                name,
                size: BodySize.medium,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.invalidate(notificationsProvider);
            context.push(AppRoutes.notifications);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 22.r,
                color: AppColors.textPrimary,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
      await PushNotificationService.instance.syncTokenToBackend();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAvailable ? "You're now online" : "You're now offline",
            ),
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
        final isAvailable =
            profile.availabilityStatus == AvailabilityStatus.available;

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
          child: Icon(Icons.refresh, color: AppColors.error, size: 24.r),
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

  Widget _buildSectionTitle(
    String title, {
    int newCount = 0,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          BodyText(title, size: BodySize.large, fontWeight: FontWeight.normal),
          if (newCount > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFBCCBCB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: BodyText(
                '$newCount new',
                size: BodySize.small,
                color: AppColors.primary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: BodyText(
              'See all',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorksModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DEDE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              BodyText(
                'How Workchop jobs work',
                size: BodySize.large,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 4.h),
              BodyText(
                'Simple 5-step flow for every booking.',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 14.h),
              _buildWalkthroughStep(
                index: 1,
                title: 'Receive request',
                subtitle:
                    'A client creates a booking and it appears as Pending.',
                icon: Icons.notifications_active_outlined,
              ),
              _buildWalkthroughStep(
                index: 2,
                title: 'Accept or reject',
                subtitle:
                    'Set agreed amount to accept, or decline with a reason.',
                icon: Icons.fact_check_outlined,
              ),
              _buildWalkthroughStep(
                index: 3,
                title: 'Wait for payment',
                subtitle: 'Client completes payment; status changes to Paid.',
                icon: Icons.payments_outlined,
              ),
              _buildWalkthroughStep(
                index: 4,
                title: 'Start job',
                subtitle: 'When paid, start the job to move it to In Progress.',
                icon: Icons.play_circle_outline,
              ),
              _buildWalkthroughStep(
                index: 5,
                title: 'Complete',
                subtitle: 'Mark complete with notes, then it moves to History.',
                icon: Icons.task_alt_outlined,
                isLast: true,
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 44.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalkthroughStep({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.r, color: AppColors.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(
                  '$index. $title',
                  size: BodySize.medium,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 2.h),
                BodyText(
                  subtitle,
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptBooking(ArtisanBooking booking) async {
    double? amount;
    final negotiationDriven =
        booking.negotiatedAmount != null &&
        (booking.negotiationStatus == 'pending_artisan' ||
            booking.negotiationStatus == 'agreed');
    if (negotiationDriven) {
      amount = booking.negotiatedAmount;
    } else {
      amount = await _showAmountInputDialog(booking);
      if (amount == null) {
        return;
      }
    }

    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .acceptBooking(bookingId: booking.id, agreedAmount: amount!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking accepted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userMessage(e))));
      }
    }
  }

  Future<void> _rejectBooking(ArtisanBooking booking) async {
    final reason = await _showTextInputDialog(
      title: 'Reject Booking',
      hint: 'Enter rejection reason',
      minLength: 10,
    );
    if (reason == null) {
      return;
    }

    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .rejectBooking(bookingId: booking.id, rejectionReason: reason);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking rejected')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userMessage(e))));
      }
    }
  }

  Future<void> _callPhone(String? phoneNumber) async {
    final value = phoneNumber?.trim() ?? '';
    if (value.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client phone number is not available')),
        );
      }
      return;
    }

    final launched = await launchPhoneDialer(value);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open dialer')));
    }
  }

  Future<double?> _showAmountInputDialog(ArtisanBooking booking) async {
    return showDialog<double>(
      context: context,
      builder: (context) => _HomeAcceptBookingDialog(booking: booking),
    );
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String hint,
    int minLength = 1,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          _HomeTextInputDialog(title: title, hint: hint, minLength: minLength),
    );
  }
}

class _HomeAcceptBookingDialog extends StatefulWidget {
  const _HomeAcceptBookingDialog({required this.booking});

  final ArtisanBooking booking;

  @override
  State<_HomeAcceptBookingDialog> createState() =>
      _HomeAcceptBookingDialogState();
}

class _HomeAcceptBookingDialogState extends State<_HomeAcceptBookingDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (((widget.booking.budgetMin + widget.booking.budgetMax) / 2))
          .toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accept Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set amount between ₦${widget.booking.budgetMin.toStringAsFixed(0)} and ₦${widget.booking.budgetMax.toStringAsFixed(0)}',
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Agreed amount',
              prefixText: '₦ ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_controller.text.trim());
            if (amount == null) return;
            Navigator.pop(context, amount);
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

class _HomeTextInputDialog extends StatefulWidget {
  const _HomeTextInputDialog({
    required this.title,
    required this.hint,
    required this.minLength,
  });

  final String title;
  final String hint;
  final int minLength;

  @override
  State<_HomeTextInputDialog> createState() => _HomeTextInputDialogState();
}

class _HomeTextInputDialogState extends State<_HomeTextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        minLines: 3,
        maxLines: 5,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.length < widget.minLength) return;
            Navigator.pop(context, value);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
