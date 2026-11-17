import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/artisan.dart';
import '../../../search/presentation/providers/all_artisans_provider.dart';
import '../../../../core/network/dio_error_mapper.dart';

class AllArtisansPage extends ConsumerWidget {
  const AllArtisansPage({super.key});

  static const double _nearbyThresholdKm = 10.0;

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(allArtisansProvider);
    await ref.read(allArtisansProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(allArtisansProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('All artisans'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: artisansAsync.when(
          data: (artisans) {
            if (artisans.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 180.h),
                  Padding(
                    padding: EdgeInsets.all(AppSizes.spacing),
                    child: const BodyText(
                      'No artisans found around your location.',
                      size: BodySize.medium,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            final nearby = artisans
                .where(
                  (artisan) =>
                      artisan.distanceKm != null &&
                      artisan.distanceKm! <= _nearbyThresholdKm,
                )
                .toList();
            final farther = artisans
                .where(
                  (artisan) =>
                      artisan.distanceKm == null ||
                      artisan.distanceKm! > _nearbyThresholdKm,
                )
                .toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSizes.spacing,
                AppSizes.spacingSmall,
                AppSizes.spacing,
                AppSizes.spacingLarge,
              ),
              children: [
                _buildInfoBanner(total: artisans.length, nearby: nearby.length),
                SizedBox(height: 12.h),
                if (nearby.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Nearby',
                    subtitle:
                        '${nearby.length} within ${_nearbyThresholdKm.toInt()}km',
                  ),
                  SizedBox(height: 8.h),
                  ...nearby.map(
                    (artisan) => _ArtisanListItem(artisan: artisan),
                  ),
                  SizedBox(height: 14.h),
                ],
                if (farther.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Farther away',
                    subtitle: '${farther.length} artisans',
                  ),
                  SizedBox(height: 8.h),
                  ...farther.map(
                    (artisan) => _ArtisanListItem(artisan: artisan),
                  ),
                ],
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
            children: [
              SizedBox(height: 120.h),
              Padding(
                padding: EdgeInsets.all(AppSizes.spacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 40.r,
                    ),
                    SizedBox(height: 10.h),
                    BodyText(
                      'Failed to load artisans',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 6.h),
                    BodyText(
                      userMessage(error),
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(allArtisansProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner({required int total, required int nearby}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFA),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18.r, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: BodyText(
              '$total artisans found, $nearby nearby. Verified and unverified are shown.',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BodyText(title, size: BodySize.large, fontWeight: FontWeight.w700),
        BodyText(
          subtitle,
          size: BodySize.small,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

class _ArtisanListItem extends StatelessWidget {
  final Artisan artisan;

  const _ArtisanListItem({required this.artisan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => context.push(AppRoutes.artisanProfile, extra: artisan),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BodyText(
                              artisan.name,
                              size: BodySize.medium,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _statusBadge(artisan.isVerified),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      BodyText(
                        artisan.service,
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 6.h,
                        children: [
                          if (artisan.distanceKm != null)
                            _meta(
                              icon: Icons.location_on_outlined,
                              label:
                                  '${artisan.distanceKm!.toStringAsFixed(1)} km away',
                            ),
                          if (artisan.rating > 0)
                            _meta(
                              icon: Icons.star_rounded,
                              label: artisan.ratingsCount != null
                                  ? '${artisan.rating.toStringAsFixed(1)} (${artisan.ratingsCount})'
                                  : artisan.rating.toStringAsFixed(1),
                              iconColor: Colors.amber.shade700,
                            ),
                          if (artisan.jobsCompleted > 0)
                            _meta(
                              icon: Icons.work_outline,
                              label: '${artisan.jobsCompleted} jobs',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (artisan.avatarUrl.startsWith('http://') ||
        artisan.avatarUrl.startsWith('https://')) {
      return CircleAvatar(
        radius: 24.r,
        backgroundColor: AppColors.cardBackground,
        backgroundImage: NetworkImage(artisan.avatarUrl),
      );
    }

    return CircleAvatar(
      radius: 24.r,
      backgroundColor: AppColors.cardBackground,
      backgroundImage: AssetImage(artisan.avatarUrl),
    );
  }

  Widget _statusBadge(bool verified) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: verified ? const Color(0xFFEAF7EE) : const Color(0xFFFDEEEE),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified : Icons.gpp_bad_outlined,
            size: 12.r,
            color: verified ? Colors.green.shade700 : Colors.red.shade700,
          ),
          SizedBox(width: 4.w),
          BodyText(
            verified ? 'Verified' : 'Unverified',
            size: BodySize.small,
            color: verified ? Colors.green.shade700 : Colors.red.shade700,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _meta({
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: iconColor ?? AppColors.textSecondary),
        SizedBox(width: 3.w),
        BodyText(label, size: BodySize.small, color: AppColors.textSecondary),
      ],
    );
  }
}
