import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../search_result/domain/models/store.dart';

class NearbyStoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const NearbyStoreCard({
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
            // Left Section - Avatar and Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and Name Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Avatar
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: AssetImage(store.avatarUrl),
                      ),
                      SizedBox(width: AppSizes.spacingSmall),

                      // Name and Owner Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store Name
                            BodyText(
                              store.name,
                              size: BodySize.small,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(height: 1.h),

                            // Owner Name
                            BodyText(
                              store.ownerName,
                              size: BodySize.small,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

                  // Description (full width of left section)
                  BodyText(
                    store.description,
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.spacing),

            // Right Section - Store Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Image.asset(
                store.imageUrl,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
