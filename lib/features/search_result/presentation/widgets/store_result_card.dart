import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/store.dart';

class StoreResultCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const StoreResultCard({
    super.key,
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacing),
        padding: EdgeInsets.all(AppSizes.spacingSmall),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Avatar, Name, Description, Rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and Name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: AssetImage(store.avatarUrl),
                      ),
                      SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyText(
                              store.name,
                              size: BodySize.small,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            BodyText(
                              store.ownerName,
                              size: BodySize.small,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

                  // Description
                  BodyText(
                    store.description,
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    height: 1.4,
                  ),
                  SizedBox(height: AppSizes.spacingSmall + 4.h),

                  // Rating and Distance
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 1.w),
                      BodyText(
                        '${store.rating} (${store.salesCount} sales)',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSizes.spacingSmall),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 1.w),
                      BodyText(
                        store.distance,
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),

            // Right side - Store Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Image.asset(
                store.imageUrl,
                width: 80.w,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
