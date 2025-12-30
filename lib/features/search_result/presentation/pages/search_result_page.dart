import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/search_result_data.dart';
import '../widgets/artisan_result_card.dart';
import '../widgets/store_result_card.dart';
import '../widgets/filter_tab_selector.dart';

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
  FilterTab _selectedTab = FilterTab.all;

  void _onTabChanged(FilterTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter content based on selected tab
    final showArtisans = _selectedTab == FilterTab.all || _selectedTab == FilterTab.artisans;
    final showStores = _selectedTab == FilterTab.all || _selectedTab == FilterTab.stores;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button, search query, and search icon
            Padding(
              padding: EdgeInsets.all(AppSizes.spacing),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24.r,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Search Query Text
                  Expanded(
                    child: Center(
                      child: HeaderText(
                        widget.query,
                        size: HeaderSize.h4,
                      ),
                    ),
                  ),

                  // Search Icon
                  GestureDetector(
                    onTap: () {
                      // TODO: Open search
                    },
                    child: Icon(
                      Icons.search,
                      size: 24.r,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Location Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      BodyText(
                        '24, New Stadium Road, Uyo, AKS',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () {
                      // TODO: Edit location
                    },
                    child: const BodyText(
                      'Edit service location',
                      size: BodySize.small,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacing),

            // Filter Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
              child: FilterTabSelector(
                selectedTab: _selectedTab,
                onTabChanged: _onTabChanged,
              ),
            ),
            SizedBox(height: AppSizes.spacing + 4.h),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artisans Section
                    if (showArtisans) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BodyText(
                            'Artisans near you',
                            size: BodySize.medium,
                            fontWeight: FontWeight.bold,
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to all artisans
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
                      SizedBox(height: AppSizes.spacing),

                      // Artisan Cards
                      ...SearchResultData.artisans.map((artisan) {
                        final distances = ['3m away', '34km away', 'Ogun State'];
                        final index = SearchResultData.artisans.indexOf(artisan);
                        return ArtisanResultCard(
                          artisan: artisan,
                          distance: distances[index % distances.length],
                        );
                      }),

                      SizedBox(height: AppSizes.spacing + 4.h),
                    ],

                    // Stores Section
                    if (showStores) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const BodyText(
                            'Nearby stores',
                            size: BodySize.medium,
                            fontWeight: FontWeight.bold,
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to all stores
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
                      SizedBox(height: AppSizes.spacing),

                      // Store Cards
                      ...SearchResultData.stores.map((store) => StoreResultCard(
                            store: store,
                          )),

                      SizedBox(height: AppSizes.spacingLarge),
                    ],
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
