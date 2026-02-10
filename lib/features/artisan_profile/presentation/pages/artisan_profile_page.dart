import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../widgets/rating_distribution.dart';
import '../widgets/portfolio_item_widget.dart';
import '../widgets/review_item_widget.dart';
import '../providers/artisan_public_profile_providers.dart';
import '../../domain/models/artisan_public_profile.dart';

class ArtisanProfilePage extends ConsumerStatefulWidget {
  final Artisan artisan;

  const ArtisanProfilePage({super.key, required this.artisan});

  @override
  ConsumerState<ArtisanProfilePage> createState() => _ArtisanProfilePageState();
}

class _ArtisanProfilePageState extends ConsumerState<ArtisanProfilePage> {
  int _currentTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _onShare() {
    // TODO: Implement share functionality
  }

  void _onBookService() {
    context.push(AppRoutes.instantService, extra: widget.artisan);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(
      artisanPublicProfileProvider(widget.artisan.id),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: profileAsync.when(
                data: (profile) => _buildContent(profile),
                loading: () => _buildLoadingSkeleton(),
                error: (error, stack) => _buildError(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacing),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(
              Icons.arrow_back,
              size: 24.r,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Center(
              child: HeaderText('Artisan Info', size: HeaderSize.h4),
            ),
          ),
          GestureDetector(
            onTap: _onShare,
            child: Icon(
              null,
              size: 24.r,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ArtisanPublicProfile profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile),
          SizedBox(height: AppSizes.spacing),
          _buildRatingSection(profile),
          SizedBox(height: AppSizes.spacing),
          _buildActionButtons(),
          SizedBox(height: AppSizes.spacingLarge),
          _buildTabBar(),
          SizedBox(height: AppSizes.spacingSmall),
          if (_currentTabIndex == 0) _buildAboutTab(profile),
          if (_currentTabIndex == 1) _buildPortfolioTab(),
          if (_currentTabIndex == 2) _buildReviewTab(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ArtisanPublicProfile profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundImage: _resolveImageProvider(widget.artisan.avatarUrl),
        ),
        SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4.w,
                children: [
                  BodyText(
                    profile.fullName,
                    size: BodySize.small,
                    fontWeight: FontWeight.w600,
                  ),
                  if (widget.artisan.isVerified)
                    Icon(Icons.verified, size: 16.r, color: Colors.red),
                  if (profile.specialization != null)
                    BodyText(
                      profile.specialization!,
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
              SizedBox(height: 2.h),
              if (profile.locationAddress != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.r,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: BodyText(
                        profile.locationAddress!,
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider _resolveImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }
    return AssetImage(imageUrl);
  }

  Widget _buildRatingSection(ArtisanPublicProfile profile) {
    final reviewsAsync = ref.watch(artisanReviewsProvider(widget.artisan.id));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderText(
              profile.averageRating.toStringAsFixed(1),
              size: HeaderSize.h4,
              color: AppColors.primary,
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < profile.averageRating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 14.r,
                  color: AppColors.primary,
                );
              }),
            ),
            SizedBox(height: 2.h),
            BodyText(
              '${profile.totalRatings} reviews',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 4.h),
            HeaderText(
              profile.totalJobsCompleted.toString(),
              size: HeaderSize.h4,
              color: AppColors.primary,
            ),
            const BodyText(
              'Total jobs',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        SizedBox(width: AppSizes.spacingLarge + 8.w),
        Expanded(
          child: reviewsAsync.when(
            data: (reviewsData) {
              final distribution = reviewsData.ratingDistribution;
              return RatingDistribution(
                distribution: {
                  5: distribution.percentageFor(5),
                  4: distribution.percentageFor(4),
                  3: distribution.percentageFor(3),
                  2: distribution.percentageFor(2),
                  1: distribution.percentageFor(1),
                },
              );
            },
            loading: () => _buildRatingDistributionSkeleton(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistributionSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push(AppRoutes.scheduleService, extra: widget.artisan);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Center(
                child: BodyText(
                  'Schedule Service',
                  size: BodySize.small,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.spacing),
        Expanded(
          child: GestureDetector(
            onTap: _onBookService,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Center(
                child: BodyText(
                  'Instant Service',
                  size: BodySize.small,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'About',
            isActive: _currentTabIndex == 0,
            onTap: () => _onTabChanged(0),
          ),
          SizedBox(width: 4.w),
          _TabButton(
            label: 'Portfolio',
            isActive: _currentTabIndex == 1,
            onTap: () => _onTabChanged(1),
          ),
          SizedBox(width: 4.w),
          _TabButton(
            label: 'Review',
            isActive: _currentTabIndex == 2,
            onTap: () => _onTabChanged(2),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(ArtisanPublicProfile profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacing),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BodyText(
            'Bio',
            size: BodySize.medium,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          BodyText(
            profile.bio ?? 'No bio available',
            size: BodySize.small,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          if (profile.specialization != null) ...[
            SizedBox(height: AppSizes.spacingLarge),
            const BodyText(
              'Specialization',
              size: BodySize.medium,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.spacingSmall),
            BodyText(
              profile.specialization!,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
          if (profile.yearsOfExperience != null) ...[
            SizedBox(height: AppSizes.spacingLarge),
            const BodyText(
              'Experience',
              size: BodySize.medium,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.spacingSmall),
            BodyText(
              '${profile.yearsOfExperience} years',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
          if (profile.hourlyRateMin != null &&
              profile.hourlyRateMax != null) ...[
            SizedBox(height: AppSizes.spacingLarge),
            const BodyText(
              'Hourly Rate',
              size: BodySize.medium,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.spacingSmall),
            BodyText(
              profile.hourlyRateRange,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    final portfolioAsync = ref.watch(
      artisanPortfolioProvider(widget.artisan.id),
    );

    return portfolioAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState('No portfolio items yet');
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.spacing,
            mainAxisSpacing: AppSizes.spacing,
            childAspectRatio: 0.95,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return PortfolioItemWidget(
              key: ValueKey(items[index].id),
              item: items[index],
            );
          },
        );
      },
      loading: () => _buildPortfolioSkeleton(),
      error: (error, stack) =>
          _buildErrorWithRetry('Failed to load portfolio', () {
            ref.invalidate(artisanPortfolioProvider(widget.artisan.id));
          }),
    );
  }

  Widget _buildReviewTab() {
    final reviewsAsync = ref.watch(artisanReviewsProvider(widget.artisan.id));

    return reviewsAsync.when(
      data: (reviewsData) {
        if (reviewsData.reviews.isEmpty) {
          return _buildEmptyState('No reviews yet');
        }
        return Column(
          children: reviewsData.reviews
              .map((review) => ReviewItemWidget(review: review))
              .toList(),
        );
      },
      loading: () => _buildReviewsSkeleton(),
      error: (error, stack) =>
          _buildErrorWithRetry('Failed to load reviews', () {
            ref.invalidate(artisanReviewsProvider(widget.artisan.id));
          }),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingLarge * 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48.r,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.spacing),
            BodyText(
              message,
              size: BodySize.medium,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWithRetry(String message, VoidCallback onRetry) {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingLarge * 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
            SizedBox(height: AppSizes.spacing),
            BodyText(message, size: BodySize.medium, color: AppColors.error),
            SizedBox(height: AppSizes.spacing),
            TextButton(
              onPressed: onRetry,
              child: const BodyText(
                'Tap to retry',
                size: BodySize.small,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spacing,
        mainAxisSpacing: AppSizes.spacing,
        childAspectRatio: 0.95,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
        );
      },
    );
  }

  Widget _buildReviewsSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.spacing),
          padding: EdgeInsets.all(AppSizes.spacing),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 80.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.spacingSmall),
              Container(
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 200.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
          SizedBox(height: 16.h),
          BodyText(
            'Failed to load profile',
            size: BodySize.medium,
            color: AppColors.error,
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () {
              ref.invalidate(artisanPublicProfileProvider(widget.artisan.id));
            },
            child: const BodyText(
              'Tap to retry',
              size: BodySize.small,
              color: AppColors.primary,
            ),
          ),
        ],
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
