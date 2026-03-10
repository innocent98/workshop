import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/service_category.dart';
import '../widgets/service_category_list_item.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../search/presentation/providers/search_history_provider.dart';
import '../../../search/presentation/widgets/search_suggestion_item.dart';

class ServiceCategoriesPage extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final String? initialCategoryName;

  const ServiceCategoriesPage({
    super.key,
    this.initialCategoryId,
    this.initialCategoryName,
  });

  @override
  ConsumerState<ServiceCategoriesPage> createState() =>
      _ServiceCategoriesPageState();
}

class _ServiceCategoriesPageState extends ConsumerState<ServiceCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  bool get _isServicesMode => _selectedCategoryId != null;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _selectedCategoryName = widget.initialCategoryName;
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Only show suggestion/history panel while user is actively in the search field.
      _showSuggestions = _searchFocusNode.hasFocus;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus;
    });
  }

  void _onSuggestionTap(String query) {
    // Add to history
    ref.read(searchHistoryProvider.notifier).addSearch(query);

    // Clear search and hide suggestions
    _searchController.clear();
    _searchFocusNode.unfocus();

    // Navigate to search results
    context.push('${AppRoutes.searchResult}?query=$query');
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _onSuggestionTap(query);
    }
  }

  void _onCategorySelected(String categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _showSuggestions = false;
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _onBackPressed() {
    if (_isServicesMode) {
      setState(() {
        _selectedCategoryId = null;
        _selectedCategoryName = null;
        _showSuggestions = false;
      });
      _searchController.clear();
      _searchFocusNode.unfocus();
      return;
    }
    context.pop();
  }

  Widget _buildServiceListItem({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      leading: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.design_services,
          color: AppColors.primary,
          size: 16.r,
        ),
      ),
      title: BodyText(title, size: BodySize.small, fontWeight: FontWeight.w600),
      subtitle: (subtitle != null && subtitle.trim().isNotEmpty)
          ? BodyText(
              subtitle,
              size: BodySize.small,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        size: 18.r,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final typed = _searchController.text.toLowerCase().trim();
    final allServices = servicesAsync.value ?? const <dynamic>[];
    final servicesPool = _isServicesMode
        ? allServices
              .where(
                (service) =>
                    service.categoryId?.toString() == _selectedCategoryId,
              )
              .toList()
        : allServices;
    final serviceSuggestions = servicesPool
        .map((service) => service.name as String)
        .where((name) => typed.isNotEmpty && name.toLowerCase().contains(typed))
        .toSet()
        .toList();

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
          onPressed: _onBackPressed,
        ),
        centerTitle: true,
        title: HeaderText(
          _isServicesMode ? 'Services' : 'Service Categories',
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
                        focusNode: _searchFocusNode,
                        onSubmitted: _onSearchSubmitted,
                        style: TextStyle(
                          fontSize: AppSizes.caption,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: _isServicesMode
                              ? 'Search services in this category'
                              : 'What service do you need?',
                          hintStyle: TextStyle(
                            fontSize: AppSizes.caption,
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

            // Suggestions/History or Service Categories List
            if (_showSuggestions && _searchController.text.isNotEmpty)
              // Show suggestions when user is typing
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                  children: [
                    // Matching history items first
                    ...searchHistory
                        .where(
                          (item) => item.toLowerCase().contains(
                            _searchController.text.toLowerCase().trim(),
                          ),
                        )
                        .map(
                          (query) => SearchSuggestionItem(
                            text: query,
                            isHistory: true,
                            onTap: () => _onSuggestionTap(query),
                          ),
                        ),

                    // Then service-name suggestions from API services list
                    ...serviceSuggestions
                        .where(
                          (suggestion) => !searchHistory.any(
                            (h) =>
                                h.toLowerCase().trim() ==
                                suggestion.toLowerCase().trim(),
                          ),
                        )
                        .map(
                          (suggestion) => SearchSuggestionItem(
                            text: suggestion,
                            isHistory: false,
                            onTap: () => _onSuggestionTap(suggestion),
                          ),
                        ),
                  ],
                ),
              )
            else if (_showSuggestions && _searchController.text.isEmpty)
              // Show all history when focused but empty
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                  children: searchHistory
                      .map(
                        (query) => SearchSuggestionItem(
                          text: query,
                          isHistory: true,
                          onTap: () => _onSuggestionTap(query),
                        ),
                      )
                      .toList(),
                ),
              )
            else
              // Categories list from API (GET /services/categories)
              Expanded(
                child: _isServicesMode
                    ? Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.spacing,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: BodyText(
                                      _selectedCategoryName ?? '',
                                      size: BodySize.small,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId = null;
                                        _selectedCategoryName = null;
                                      });
                                    },
                                    child: BodyText(
                                      'Change',
                                      size: BodySize.small,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Expanded(
                            child: servicesAsync.when(
                              data: (services) {
                                final filteredServices = services
                                    .where(
                                      (service) =>
                                          service.categoryId?.toString() ==
                                          _selectedCategoryId,
                                    )
                                    .toList();
                                if (services.isEmpty) {
                                  return ListView(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.spacing,
                                    ),
                                    children: [
                                      SizedBox(height: 60.h),
                                      BodyText(
                                        'No services found in this category',
                                        size: BodySize.small,
                                        color: AppColors.textSecondary,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                }
                                if (filteredServices.isEmpty) {
                                  return ListView(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.spacing,
                                    ),
                                    children: [
                                      SizedBox(height: 60.h),
                                      BodyText(
                                        'No services found in this category',
                                        size: BodySize.small,
                                        color: AppColors.textSecondary,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                }
                                return ListView.separated(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.spacing,
                                  ),
                                  itemCount: filteredServices.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1.h,
                                    color: AppColors.divider,
                                  ),
                                  itemBuilder: (context, index) {
                                    final service = filteredServices[index];
                                    return _buildServiceListItem(
                                      title: service.name,
                                      subtitle: service.description,
                                      onTap: () =>
                                          _onSuggestionTap(service.name),
                                    );
                                  },
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, _) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BodyText(
                                      'Failed to load services',
                                      size: BodySize.medium,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(height: 8.h),
                                    TextButton(
                                      onPressed: () =>
                                          ref.invalidate(servicesProvider),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : categoriesAsync.when(
                        data: (categories) => ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.spacing,
                          ),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 0.h),
                          itemBuilder: (context, index) {
                            final categoryData = categories[index];
                            final category = ServiceCategory(
                              id: categoryData.id,
                              name: categoryData.name,
                              icon: _iconForCategory(categoryData.icon),
                            );
                            return ServiceCategoryListItem(
                              category: category,
                              onTap: () => _onCategorySelected(
                                categoryData.id,
                                categoryData.name,
                              ),
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BodyText(
                                'Failed to load categories',
                                size: BodySize.medium,
                                color: AppColors.error,
                              ),
                              SizedBox(height: 8.h),
                              TextButton(
                                onPressed: () =>
                                    ref.invalidate(serviceCategoriesProvider),
                                child: const Text('Retry'),
                              ),
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
}
