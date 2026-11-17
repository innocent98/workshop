import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/support_contact.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../widgets/service_category_chip.dart';
import '../widgets/artisan_card.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../search/presentation/providers/nearby_artisans_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../core/network/dio_error_mapper.dart';

class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  IconData _iconForCategory(String? iconName) {
    switch (iconName) {
      case 'construction':
        return Icons.construction;
      case 'directions_car':
        return Icons.directions_car;
      case 'bolt':
        return Icons.bolt;
      case 'style':
        return Icons.style;
      case 'restaurant':
        return Icons.restaurant;
      case 'handyman':
        return Icons.handyman;
      case 'print':
        return Icons.print;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.refresh(serviceCategoriesProvider.future),
      ref.refresh(servicesProvider.future),
      ref.refresh(nearbyArtisansProvider.future),
      ref.refresh(notificationsProvider.future),
    ]);
  }

  void _onSearchTap() {
    context.push(AppRoutes.serviceCategories);
  }

  void _onNotificationTap() {
    ref.invalidate(notificationsProvider);
    context.push(AppRoutes.notifications);
  }

  Future<void> _onCallNowTap() async {
    final launched = await launchPhoneDialer(SupportContact.phone);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open dialer right now')),
      );
    }
  }

  void _onBookServiceTap() {
    _onSearchTap();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(
      notificationsProvider.select((state) {
        return state.maybeWhen(
          data: (value) => value.unreadCount,
          orElse: () => 0,
        );
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Section with Search Bar
                      Padding(
                        padding: EdgeInsets.all(AppSizes.spacing),
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
                                    color: const Color(
                                      0xFFF5F5F5,
                                    ), // Search bar background
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radius,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: AppSizes.iconSize,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(
                                        width: AppSizes.spacingSmall + 4.w,
                                      ),
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
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    size: 28.r,
                                    color: AppColors.textPrimary,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -2,
                                      top: -2,
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
                                          color: Color(0xFFFF0000),
                                          borderRadius: BorderRadius.circular(
                                            999.r,
                                          ),
                                        ),
                                        child: Text(
                                          unreadCount > 99
                                              ? '99+'
                                              : unreadCount.toString(),
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
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
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
                                      style: TextStyle(
                                        fontSize: AppSizes.caption,
                                      ),
                                    ),
                                    TextSpan(
                                      text: SupportContact.phoneDisplay,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing,
                        ),
                        child: PrimaryButton(
                          label: 'Book Service',
                          onPressed: _onBookServiceTap,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingLarge + 8.h),

                      // Verified Artisans Nearby Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing,
                        ),
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
                                context.push(AppRoutes.allArtisans);
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

                      // How It Works Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const BodyText(
                              'How it works',
                              size: BodySize.large,
                              fontWeight: FontWeight.bold,
                            ),
                            GestureDetector(
                              onTap: _showHowItWorksModal,
                              child: BodyText(
                                'Open',
                                size: BodySize.small,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.spacing),

                      // How It Works Walkthrough Card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing,
                        ),
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BodyText(
                                        'Service booking walkthrough',
                                        size: BodySize.medium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(height: 2.h),
                                      BodyText(
                                        'See the steps from request to completion.',
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
                      SizedBox(height: AppSizes.spacingLarge),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategories() {
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
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
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: AppSizes.spacingSmall),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ServiceCategoryChip(
                label: category.name,
                icon: _iconForCategory(category.icon),
                onTap: () => _onCategoryTap(category.id, category.name),
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
              Icon(Icons.error_outline, size: 16.r, color: Colors.red),
              SizedBox(width: 8.w),
              BodyText(
                'Failed to load services',
                size: BodySize.small,
                color: Colors.red,
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () => ref.refresh(serviceCategoriesProvider),
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
                Icon(Icons.error_outline, size: 48.r, color: Colors.red),
                SizedBox(height: 8.h),
                BodyText(
                  'Failed to load artisans',
                  size: BodySize.medium,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                BodyText(
                  userMessage(error),
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

  Future<void> _showHowItWorksModal() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E0E0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                BodyText(
                  'How it works',
                  size: BodySize.large,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 12.h),
                _buildWalkthroughStep(
                  step: '1',
                  title: 'Choose a service',
                  subtitle: 'Search and select what you need.',
                ),
                _buildWalkthroughStep(
                  step: '2',
                  title: 'Pick an artisan',
                  subtitle: 'Compare ratings, distance, and profile.',
                ),
                _buildWalkthroughStep(
                  step: '3',
                  title: 'Book and track',
                  subtitle: 'Send request and monitor progress in jobs.',
                ),
                _buildWalkthroughStep(
                  step: '4',
                  title: 'Pay and review',
                  subtitle: 'Complete payment and leave a rating.',
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalkthroughStep({
    required String step,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26.w,
            height: 26.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: BodyText(
                step,
                size: BodySize.small,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(
                  title,
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

  void _onCategoryTap(String categoryId, String categoryName) {
    final encodedId = Uri.encodeComponent(categoryId);
    final encodedName = Uri.encodeComponent(categoryName);
    context.push(
      '${AppRoutes.serviceCategories}?category_id=$encodedId&category_name=$encodedName',
    );
  }
}
