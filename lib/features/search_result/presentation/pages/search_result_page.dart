import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../client_profile/presentation/providers/client_profile_provider.dart';
import '../../../search/presentation/providers/search_artisans_by_query_provider.dart';
import '../widgets/artisan_result_card.dart';
import '../../../search/presentation/providers/search_history_provider.dart';
import 'service_location_picker_page.dart';

class SearchResultPage extends ConsumerStatefulWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  ServiceLocationSelection? _selectedLocation;

  double? get _selectedLat => _selectedLocation?.latitude;
  double? get _selectedLon => _selectedLocation?.longitude;

  SearchArtisansQueryInput _currentSearchInput({
    required double fallbackLat,
    required double fallbackLon,
  }) {
    return SearchArtisansQueryInput(
      query: widget.query,
      latitude: _selectedLat ?? fallbackLat,
      longitude: _selectedLon ?? fallbackLon,
    );
  }

  Future<void> _openLocationPicker({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final picked = await Navigator.of(context).push<ServiceLocationSelection>(
      MaterialPageRoute(
        builder: (_) => ServiceLocationPickerPage(
          initialLatitude: latitude,
          initialLongitude: longitude,
          initialAddress: address,
        ),
      ),
    );

    if (picked == null) return;

    if (!mounted) return;
    setState(() => _selectedLocation = picked);
    ref.invalidate(
      searchArtisansByQueryProvider(
        SearchArtisansQueryInput(
          query: widget.query,
          latitude: picked.latitude,
          longitude: picked.longitude,
        ),
      ),
    );

    try {
      await ref
          .read(clientProfileRemoteDataSourceProvider)
          .updateMyLocation(
            latitude: picked.latitude,
            longitude: picked.longitude,
            address: picked.address,
          );
      ref.invalidate(clientProfileProvider);
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    final clientProfile = ref.read(clientProfileProvider).asData?.value;
    final location = ref.read(locationProvider).asData?.value;

    final lat =
        _selectedLat ?? clientProfile?.locationLatitude ?? location?.latitude;
    final lon =
        _selectedLon ?? clientProfile?.locationLongitude ?? location?.longitude;

    if (lat == null || lon == null) return;

    final input = _currentSearchInput(fallbackLat: lat, fallbackLon: lon);
    ref.invalidate(searchArtisansByQueryProvider(input));
    await ref.read(searchArtisansByQueryProvider(input).future);
  }

  @override
  Widget build(BuildContext context) {
    final clientProfileAsync = ref.watch(clientProfileProvider);
    final locationAsync = ref.watch(locationProvider);

    final clientProfile = clientProfileAsync.asData?.value;
    final location = locationAsync.asData?.value;

    final fallbackLat = location?.latitude ?? 6.5244;
    final fallbackLon = location?.longitude ?? 3.3792;
    final effectiveLat =
        _selectedLat ?? clientProfile?.locationLatitude ?? fallbackLat;
    final effectiveLon =
        _selectedLon ?? clientProfile?.locationLongitude ?? fallbackLon;
    final effectiveAddress =
        _selectedLocation?.address ??
        clientProfile?.locationAddress ??
        '${effectiveLat.toStringAsFixed(5)}, ${effectiveLon.toStringAsFixed(5)}';

    final searchInput = _currentSearchInput(
      fallbackLat: effectiveLat,
      fallbackLon: effectiveLon,
    );
    final artisansAsync = ref.watch(searchArtisansByQueryProvider(searchInput));

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
                  SizedBox(
                    width: 32.w,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24.r,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Search Query Text
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: HeaderText(
                        widget.query,
                        size: HeaderSize.h4,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Search Icon
                  SizedBox(
                    width: 32.w,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(searchHistoryProvider.notifier)
                            .addSearch(widget.query);
                      },
                      child: Icon(
                        Icons.search,
                        size: 24.r,
                        color: AppColors.textPrimary,
                      ),
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
                      Expanded(
                        child: BodyText(
                          effectiveAddress,
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () => _openLocationPicker(
                      latitude: effectiveLat,
                      longitude: effectiveLon,
                      address: effectiveAddress,
                    ),
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

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: artisansAsync.when(
                  data: (artisans) {
                    if (artisans.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing,
                        ),
                        children: [
                          SizedBox(height: 120.h),
                          Icon(
                            Icons.person_search,
                            size: 50.r,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8.h),
                          BodyText(
                            'No artisans found for "${widget.query}"',
                            size: BodySize.medium,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.spacing,
                        0,
                        AppSizes.spacing,
                        AppSizes.spacingLarge,
                      ),
                      children: [
                        const BodyText(
                          'Artisans near you',
                          size: BodySize.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: AppSizes.spacing),
                        ...artisans.map(
                          (artisan) => ArtisanResultCard(
                            key: ValueKey(artisan.id),
                            artisan: artisan,
                            distance: artisan.distanceKm != null
                                ? '${artisan.distanceKm!.toStringAsFixed(1)} km away'
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 240),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  error: (error, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppSizes.spacing),
                    children: [
                      SizedBox(height: 120.h),
                      Icon(
                        Icons.error_outline,
                        size: 44.r,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 10.h),
                      BodyText(
                        'Failed to load artisans',
                        size: BodySize.medium,
                        color: AppColors.error,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      BodyText(
                        error.toString(),
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          searchArtisansByQueryProvider(searchInput),
                        ),
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
