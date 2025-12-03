import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/navigation/bottom_nav_bar.dart';
import '../../data/mock_data.dart';
import '../widgets/service_category_chip.dart';
import '../widgets/artisan_card.dart';
import '../widgets/blog_post_card.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentNavIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _onSearchTap() {
    context.push(AppRoutes.search);
  }

  void _onNotificationTap() {
    // TODO: Navigate to notifications
  }

  void _onCallNowTap() {
    // TODO: Implement call functionality
  }

  void _onBookServiceTap() {
    // TODO: Navigate to book service page
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section with Search Bar
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.spacing,
                        AppSizes.spacing,
                        AppSizes.spacing,
                        AppSizes.spacing,
                      ),
                      child: Row(
                        children: [
                          // Search Bar
                          Expanded(
                            child: GestureDetector(
                              onTap: _onSearchTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.spacing,
                                  vertical: 14.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5), // Search bar background
                                  borderRadius: BorderRadius.circular(AppSizes.radius),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: AppSizes.iconSize,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(width: AppSizes.spacingSmall + 4.w),
                                    BodyText(
                                      'What service do you need?',
                                      size: BodySize.small,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacing - 4.w),

                          // Notification Bell
                          GestureDetector(
                            onTap: _onNotificationTap,
                            child: Stack(
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  size: 28.r,
                                  color: AppColors.textPrimary,
                                ),
                                // Red dot indicator
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    width: 8.r,
                                    height: 8.r,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF0000),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Call Banner
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2725B),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: AppSizes.caption,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'CALL US TO GET AN ARTISAN ',
                                  ),
                                  TextSpan(
                                    text: '0702 500 0478',
                                    style: TextStyle(
                                      fontSize: AppSizes.caption,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingSmall + 4.w),
                          GestureDetector(
                            onTap: _onCallNowTap,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.spacing,
                                vertical: AppSizes.spacingSmall,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: BodyText(
                                'CALL NOW',
                                size: BodySize.small,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE2725B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.spacing + 4.h),

                    // Service Categories (Horizontal Scroll)
                    SizedBox(
                      height: 44.h,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                        scrollDirection: Axis.horizontal,
                        itemCount: MockData.serviceCategories.length,
                        separatorBuilder: (context, index) => SizedBox(width: AppSizes.spacingSmall),
                        itemBuilder: (context, index) {
                          return ServiceCategoryChip(
                            category: MockData.serviceCategories[index],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSizes.spacing + 4.h),

                    // Book Service Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      child: PrimaryButton(
                        label: 'Book Service',
                        onPressed: _onBookServiceTap,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge + 8.h),

                    // Nearby Verified Artisans Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      child: const BodyText(
                        'Nearby Verified Artisans',
                        size: BodySize.large,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Artisans Horizontal List
                    SizedBox(
                      height: 270.h,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: AppSizes.spacing),
                        scrollDirection: Axis.horizontal,
                        itemCount: MockData.nearbyArtisans.length,
                        itemBuilder: (context, index) {
                          return ArtisanCard(
                            artisan: MockData.nearbyArtisans[index],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSmall + 8.h),

                    // Blog Post Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      child: const BodyText(
                        'Blog Post',
                        size: BodySize.large,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Blog Posts Horizontal List
                    SizedBox(
                      height: 130.h,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: AppSizes.spacing),
                        scrollDirection: Axis.horizontal,
                        itemCount: MockData.blogPosts.length,
                        itemBuilder: (context, index) {
                          return BlogPostCard(
                            post: MockData.blogPosts[index],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge + 8.h),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }
}
