import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../data/mock_data.dart';
import '../widgets/service_category_chip.dart';
import '../widgets/artisan_card.dart';
import '../widgets/nearby_store_card.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  void _onSearchTap() {
    context.push(AppRoutes.serviceCategories);
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

  void _onCategoryTap(String categoryName) {
    // Navigate directly to search result with category
    context.push('${AppRoutes.searchResult}?query=$categoryName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                      padding: EdgeInsets.all(
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
                      // margin: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.caption,
                        vertical: 8.h,
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
                                  TextSpan(
                                    text: 'CALL US TO GET AN ARTISAN ',
                                    style: TextStyle(fontSize: AppSizes.caption,)
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
                          SizedBox(width: AppSizes.caption),
                          GestureDetector(
                            onTap: _onCallNowTap,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.spacingSmall,
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
                        itemCount: MockData.featuredServiceCategories.length,
                        separatorBuilder: (context, index) => SizedBox(width: AppSizes.spacingSmall),
                        itemBuilder: (context, index) {
                          final category = MockData.featuredServiceCategories[index];
                          return ServiceCategoryChip(
                            category: category,
                            onTap: () => _onCategoryTap(category.name),
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

                    // Verified Artisans Nearby Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BodyText(
                            'Verified artisans nearby',
                            size: BodySize.large,
                            fontWeight: FontWeight.bold,
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to all artisans page
                            },
                            child: BodyText(
                              'See all',
                              size: BodySize.small,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                          final artisan = MockData.nearbyArtisans[index];
                          return ArtisanCard(
                            artisan: artisan,
                            onTap: () {
                              context.push(AppRoutes.artisanProfile, extra: artisan);
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge + 8.h),

                    // Nearby Stores Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BodyText(
                            'Nearby stores',
                            size: BodySize.large,
                            fontWeight: FontWeight.bold,
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to all stores page
                            },
                            child: BodyText(
                              'See all',
                              size: BodySize.small,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Nearby Stores List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                      child: Column(
                        children: MockData.nearbyStores
                            .map((store) => NearbyStoreCard(store: store))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
