import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/search_result_data.dart';
import '../widgets/artisan_result_card.dart';
import '../widgets/store_result_card.dart';

class SearchResultPage extends StatefulWidget {
  final String query;

  const SearchResultPage({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  int _currentTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button, search query, and search icon
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.spacing,
                AppSizes.spacing,
                AppSizes.spacing,
                AppSizes.spacing,
              ),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20.r,
                      color: const Color(0xFFE2725B),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacing),

                  // Search Query Text
                  Expanded(
                    child: Center(
                      child: BodyText(
                        widget.query,
                        size: BodySize.large,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacing),

                  // Search Icon
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.search,
                      size: AppSizes.iconSize,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available Artisans Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BodyText(
                          'Available Artisans',
                          size: BodySize.large,
                          fontWeight: FontWeight.bold,
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to all artisans
                          },
                          child: const BodyText(
                            'See all',
                            size: BodySize.medium,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Artisan Cards
                    ...SearchResultData.artisans.map((artisan) {
                      // Generate different distances for variety
                      final distances = ['3m away', '34km away', 'Ogun State'];
                      final index = SearchResultData.artisans.indexOf(artisan);
                      return ArtisanResultCard(
                        artisan: artisan,
                        distance: distances[index % distances.length],
                      );
                    }),

                    SizedBox(height: AppSizes.spacing),

                    // Nearby Stores Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BodyText(
                          'Nearby stores',
                          size: BodySize.large,
                          fontWeight: FontWeight.bold,
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to all stores
                          },
                          child: const BodyText(
                            'See all',
                            size: BodySize.medium,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Store Cards
                    ...SearchResultData.stores.map((store) => StoreResultCard(
                          store: store,
                        )),

                    SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),

            // Bottom Tab Bar
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              // child: SafeArea(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: AppSizes.spacing,
              //       vertical: AppSizes.spacingSmall + 4.h,
              //     ),
              //     child: Row(
              //       children: [
              //         _TabButton(
              //           label: 'About',
              //           isActive: _currentTabIndex == 0,
              //           onTap: () => _onTabChanged(0),
              //         ),
              //         SizedBox(width: AppSizes.spacingSmall),
              //         _TabButton(
              //           label: 'Portfolio',
              //           isActive: _currentTabIndex == 1,
              //           onTap: () => _onTabChanged(1),
              //         ),
              //         SizedBox(width: AppSizes.spacingSmall),
              //         _TabButton(
              //           label: 'Review',
              //           isActive: _currentTabIndex == 2,
              //           onTap: () => _onTabChanged(2),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
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
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFD3D3D3),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Center(
            child: BodyText(
              label,
              size: BodySize.medium,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
