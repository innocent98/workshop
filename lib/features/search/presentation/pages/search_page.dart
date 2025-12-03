import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/search_suggestions.dart';
import '../providers/search_history_provider.dart';
import '../widgets/search_suggestion_item.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Auto-focus search field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
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
    });
  }

  void _onSuggestionTap(String query) {
    // Add to history
    ref.read(searchHistoryProvider.notifier).addSearch(query);

    // Navigate to search result page
    context.push('/search-result', extra: query);
  }

  @override
  Widget build(BuildContext context) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and search field
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
                  SizedBox(width: AppSizes.spacingSmall + 4.w),

                  // Search Field - styled like AppTextField
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                fontSize: AppSizes.body,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'What service do you need?',
                                fillColor: Colors.transparent,
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search suggestions and history
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing),
                children: [
                  // Show search history if no search query
                  if (_searchController.text.trim().isEmpty) ...[
                    ...searchHistory.map((query) => SearchSuggestionItem(
                          text: query,
                          isHistory: true,
                          onTap: () => _onSuggestionTap(query),
                        )),
                  ],

                  // Show suggestions if there's a search query
                  if (_searchController.text.trim().isNotEmpty) ...[
                    // First show matching history items
                    ...searchHistory
                        .where((item) => item.contains(_searchController.text.toLowerCase().trim()))
                        .map((query) => SearchSuggestionItem(
                              text: query,
                              isHistory: true,
                              onTap: () => _onSuggestionTap(query),
                            )),

                    // Then show other suggestions
                    ..._suggestions.map((suggestion) => SearchSuggestionItem(
                          text: suggestion,
                          isHistory: false,
                          onTap: () => _onSuggestionTap(suggestion),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
