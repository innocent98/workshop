import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/mock_data.dart';
import '../widgets/service_category_list_item.dart';

class ServiceCategoriesPage extends StatefulWidget {
  const ServiceCategoriesPage({super.key});

  @override
  State<ServiceCategoriesPage> createState() => _ServiceCategoriesPageState();
}

class _ServiceCategoriesPageState extends State<ServiceCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.push(AppRoutes.search);
    }
  }

  void _onCategoryTap(String categoryName) {
    // Navigate to search page with category filter
    context.push('${AppRoutes.searchResult}?query=$categoryName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24.r,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: HeaderText(
          'Service Categories',
          size: HeaderSize.h4,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Section
            Padding(
              padding: EdgeInsets.all(AppSizes.spacing),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: AppSizes.iconSize,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearchSubmitted,
                        style: TextStyle(
                          fontSize: AppSizes.body,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What service do you need?',
                          hintStyle: TextStyle(
                            fontSize: AppSizes.body,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Service Categories List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                itemCount: MockData.allServiceCategories.length,
                itemBuilder: (context, index) {
                  final category = MockData.allServiceCategories[index];
                  return ServiceCategoryListItem(
                    category: category,
                    onTap: () => _onCategoryTap(category.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
