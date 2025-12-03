import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/artisan.dart';

class ArtisanCard extends StatelessWidget {
  final Artisan artisan;
  final VoidCallback? onTap;

  const ArtisanCard({
    super.key,
    required this.artisan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190.w,
        margin: EdgeInsets.only(right: AppSizes.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artisan Work Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              child: Image.asset(
                artisan.imageUrl,
                width: 190.w,
                height: 190.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: AppSizes.spacingSmall + 4.h),

            // Artisan Info Row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18.r,
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
                        size: BodySize.medium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      BodyText(
                        artisan.service,
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
