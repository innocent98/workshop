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
  final String distance;
  final VoidCallback? onTap;

  const ArtisanResultCard({
    super.key,
    required this.artisan,
    required this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push(AppRoutes.artisanProfile, extra: artisan),
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
            CircleAvatar(
              radius: 24.r,
              backgroundImage: AssetImage(artisan.avatarUrl),
            ),
            SizedBox(width: AppSizes.spacingSmall),

            // Name and Service
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText(
                    artisan.name,
                    size: BodySize.small,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  BodyText(
                    artisan.service,
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
                      distance,
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
}
