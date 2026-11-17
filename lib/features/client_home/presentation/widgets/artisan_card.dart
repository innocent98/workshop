import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/common/verified_badge.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/artisan.dart';

class ArtisanCard extends StatelessWidget {
  final Artisan artisan;
  final VoidCallback? onTap;

  const ArtisanCard({super.key, required this.artisan, this.onTap});

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
            // Artisan Work Image with verification badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  child: _buildWorkImage(),
                ),
                // Verification badge
                if (artisan.isVerified)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const VerifiedBadge(size: 16),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSizes.spacingSmall + 4.h),

            // Artisan Info Row
            Row(
              children: [
                // Avatar
                _buildAvatar(),
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
                        (artisan.category != null &&
                                artisan.category!.trim().isNotEmpty)
                            ? artisan.category!
                            : artisan.service,
                        size: BodySize.tiny,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Distance and rating info
            if (artisan.distanceKm != null || artisan.rating > 0)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  children: [
                    // Distance
                    if (artisan.distanceKm != null) ...[
                      Icon(
                        Icons.location_on,
                        size: 12.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 2.w),
                      BodyText(
                        '${artisan.distanceKm!.toStringAsFixed(1)} km',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                      if (artisan.rating > 0) SizedBox(width: 8.w),
                    ],
                    // Rating
                    if (artisan.rating > 0) ...[
                      Icon(Icons.star, size: 12.r, color: Colors.amber),
                      SizedBox(width: 2.w),
                      BodyText(
                        artisan.rating.toStringAsFixed(1),
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                      if (artisan.ratingsCount != null)
                        BodyText(
                          ' (${artisan.ratingsCount})',
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkImage() {
    // Check if it's a network URL
    if (artisan.imageUrl.startsWith('http://') ||
        artisan.imageUrl.startsWith('https://')) {
      return Image.network(
        artisan.imageUrl,
        width: 190.w,
        height: 190.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 190.w,
            height: 190.h,
            color: Colors.grey.shade200,
            child: Icon(Icons.person, size: 48.r, color: Colors.grey.shade400),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 190.w,
            height: 190.h,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    // No usable work photo yet.
    return Container(
      width: 190.w,
      height: 190.h,
      color: Colors.grey.shade200,
      child: Icon(Icons.person, size: 48.r, color: Colors.grey.shade400),
    );
  }

  Widget _buildAvatar() {
    return ProfileAvatar(
      imageUrl: artisan.avatarUrl,
      name: artisan.name,
      radius: 18,
    );
  }
}
