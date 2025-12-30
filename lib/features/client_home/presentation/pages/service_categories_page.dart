import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/mock_data.dart';
import '../widgets/service_category_list_item.dart';
import '../../../search/presentation/providers/search_history_provider.dart';
import '../../../search/data/search_suggestions.dart';
import '../../../search/presentation/widgets/search_suggestion_item.dart';

class ServiceCategoriesPage extends ConsumerStatefulWidget {
  const ServiceCategoriesPage({super.key});

  @override
  ConsumerState<ServiceCategoriesPage> createState() => _ServiceCategoriesPageState();
}

class _ServiceCategoriesPageState extends ConsumerState<ServiceCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
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
      _suggestions = SearchSuggestions.getSuggestions(_searchController.text);
      _showSuggestions = true;
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

  void _onCategoryTap(String categoryName) {
    // Navigate to search page with category filter
    context.push('${AppRoutes.searchResult}?query=$categoryName');
  }

  @override
  Widget build(BuildContext context) {
    final searchHistory = ref.watch(searchHistoryProvider);

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
                        focusNode: _searchFocusNode,
                        onSubmitted: _onSearchSubmitted,
                        style: TextStyle(
                          fontSize: AppSizes.caption,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What service do you need?',
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
                        .where((item) => item
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase().trim()))
                        .map((query) => SearchSuggestionItem(
                              text: query,
                              isHistory: true,
                              onTap: () => _onSuggestionTap(query),
                            )),

                    // Then other suggestions
                    ..._suggestions.map((suggestion) => SearchSuggestionItem(
                          text: suggestion,
                          isHistory: false,
                          onTap: () => _onSuggestionTap(suggestion),
                        )),
                  ],
                ),
              )
            else if (_showSuggestions && _searchController.text.isEmpty)
              // Show all history when focused but empty
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                  children: searchHistory
                      .map((query) => SearchSuggestionItem(
                            text: query,
                            isHistory: true,
                            onTap: () => _onSuggestionTap(query),
                          ))
                      .toList(),
                ),
              )
            else
              // Service Categories List (when not focused on search)
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
