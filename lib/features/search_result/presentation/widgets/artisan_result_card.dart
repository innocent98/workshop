import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../client_home/domain/models/artisan.dart';

class ArtisanResultCard extends StatelessWidget {
  final Artisan artisan;
  final String? distance;
  final VoidCallback? onTap;

  const ArtisanResultCard({
    super.key,
    required this.artisan,
    this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ?? () => context.push(AppRoutes.artisanProfile, extra: artisan),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacing),
        padding: EdgeInsets.all(AppSizes.spacingSmall),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            SizedBox(width: AppSizes.spacingSmall),

            // Name and Service
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BodyText(
                          artisan.name,
                          size: BodySize.small,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (artisan.isVerified) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EE),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 11.r,
                                color: Colors.green.shade700,
                              ),
                              SizedBox(width: 3.w),
                              BodyText(
                                'Verified',
                                size: BodySize.small,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  BodyText(
                    (artisan.category != null &&
                            artisan.category!.trim().isNotEmpty)
                        ? artisan.category!
                        : artisan.service,
                    size: BodySize.small,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Distance and Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.r,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    BodyText(
                      distance ?? 'N/A',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14.r,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    BodyText(
                      '${artisan.rating} (${artisan.jobsCompleted} jobs)',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ],
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
}
