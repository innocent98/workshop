import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../data/artisan_profile_data.dart';
import '../widgets/rating_distribution.dart';
import '../widgets/portfolio_item_widget.dart';
import '../widgets/review_item_widget.dart';

class ArtisanProfilePage extends StatefulWidget {
  final Artisan artisan;

  const ArtisanProfilePage({
    super.key,
    required this.artisan,
  });

  @override
  State<ArtisanProfilePage> createState() => _ArtisanProfilePageState();
}

class _ArtisanProfilePageState extends State<ArtisanProfilePage> {
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
    // TODO: Navigate to booking page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
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
                      child: HeaderText(
                        'Artisan Info',
                        size: HeaderSize.h4,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onShare,
                    child: Icon(
                      Icons.bookmark_border,
                      size: 24.r,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: AssetImage(widget.artisan.avatarUrl),
                        ),
                        SizedBox(width: AppSizes.spacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name with verified badge and service
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4.w,
                                children: [
                                  BodyText(
                                    widget.artisan.name,
                                    size: BodySize.small,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  if (widget.artisan.isVerified)
                                    Icon(
                                      Icons.verified,
                                      size: 16.r,
                                      color: Colors.red,
                                    ),
                                  BodyText(
                                    widget.artisan.service,
                                    size: BodySize.small,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.r,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 2.w),
                                  const Expanded(
                                    child: BodyText(
                                      '20, Cresent Ekeng Street, Uyo',
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
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Rating section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Rating and Total Jobs
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeaderText(
                              widget.artisan.rating.toString(),
                              size: HeaderSize.h4,
                              color: AppColors.primary,
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < widget.artisan.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 14.r,
                                  color: AppColors.primary,
                                );
                              }),
                            ),
                            SizedBox(height: 2.h),
                            BodyText(
                              '${widget.artisan.jobsCompleted * 10} reviews',
                              size: BodySize.small,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 4.h),
                            HeaderText(
                              widget.artisan.jobsCompleted.toString(),
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

                        // Right: Rating distribution
                        Expanded(
                          child: RatingDistribution(
                            distribution: ArtisanProfileData.ratingDistribution,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Action Buttons
                    Row(
                      children: [
                        // Schedule Service Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Navigate to schedule service
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
                        // Instant Service Button
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
                    ),
                    SizedBox(height: AppSizes.spacingLarge),

                    // Tab bar
                    Container(
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
                    ),
                    SizedBox(height: AppSizes.spacingSmall),

                    // Tab content
                    if (_currentTabIndex == 0) _buildAboutTab(),
                    if (_currentTabIndex == 1) _buildPortfolioTab(),
                    if (_currentTabIndex == 2) _buildReviewTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAboutTab() {
    return Container(
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
          const BodyText(
            ArtisanProfileData.bio,
            size: BodySize.small,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          SizedBox(height: AppSizes.spacingLarge),
          const BodyText(
            'Skills',
            size: BodySize.medium,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          ...ArtisanProfileData.skills.map((skill) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BodyText(
                      '•  ',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                    Expanded(
                      child: BodyText(
                        skill,
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spacing,
        mainAxisSpacing: AppSizes.spacing,
        childAspectRatio: 0.95,
      ),
      itemCount: ArtisanProfileData.portfolioItems.length,
      itemBuilder: (context, index) {
        return PortfolioItemWidget(
          item: ArtisanProfileData.portfolioItems[index],
        );
      },
    );
  }

  Widget _buildReviewTab() {
    return Column(
      children: ArtisanProfileData.reviews
          .map((review) => ReviewItemWidget(review: review))
          .toList(),
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
