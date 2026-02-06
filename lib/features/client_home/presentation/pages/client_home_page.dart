import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../services/presentation/providers/services_provider.dart';
import '../../../search/presentation/providers/nearby_artisans_provider.dart';

class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
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
                    _buildServiceCategories(),
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
                    _buildNearbyArtisans(),
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

  Widget _buildServiceCategories() {
    final servicesAsync = ref.watch(servicesProvider);

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return SizedBox(
            height: 44.h,
            child: Center(
              child: BodyText(
                'No services available',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return SizedBox(
          height: 44.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (context, index) => SizedBox(width: AppSizes.spacingSmall),
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCategoryChip(
                service: service,
                onTap: () => _onCategoryTap(service.name),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 44.h,
        child: Center(
          child: SizedBox(
            width: 20.r,
            height: 20.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => SizedBox(
        height: 44.h,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 16.r,
                color: Colors.red,
              ),
              SizedBox(width: 8.w),
              BodyText(
                'Failed to load services',
                size: BodySize.small,
                color: Colors.red,
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () => ref.refresh(servicesProvider),
                child: const BodyText(
                  'Retry',
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

  Widget _buildNearbyArtisans() {
    final artisansAsync = ref.watch(nearbyArtisansProvider);

    return artisansAsync.when(
      data: (artisans) {
        if (artisans.isEmpty) {
          return SizedBox(
            height: 270.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 48.r,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  BodyText(
                    'No verified artisans nearby',
                    size: BodySize.medium,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 310.h, // Increased height for distance and rating info
          child: ListView.builder(
            padding: EdgeInsets.only(left: AppSizes.spacing),
            scrollDirection: Axis.horizontal,
            itemCount: artisans.length,
            itemBuilder: (context, index) {
              final artisan = artisans[index];
              return ArtisanCard(
                artisan: artisan,
                onTap: () {
                  context.push(AppRoutes.artisanProfile, extra: artisan);
                },
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 270.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              SizedBox(height: 8.h),
              BodyText(
                'Finding nearby artisans...',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => SizedBox(
        height: 270.h,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.r,
                  color: Colors.red,
                ),
                SizedBox(height: 8.h),
                BodyText(
                  'Failed to load artisans',
                  size: BodySize.medium,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                BodyText(
                  error.toString(),
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                SizedBox(height: 12.h),
                PrimaryButton(
                  label: 'Retry',
                  onPressed: () => ref.refresh(nearbyArtisansProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(String categoryName) {
    // Navigate directly to search result with category
    context.push('${AppRoutes.searchResult}?query=$categoryName');
  }
}
