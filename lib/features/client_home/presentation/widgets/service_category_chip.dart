import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class ServiceCategoryChip extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final VoidCallback? onTap;

  const ServiceCategoryChip({
    super.key,
    required this.label,
    this.imageUrl,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing,
          vertical: AppSizes.spacingSmall + 4.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service image from network or fallback icon
            _buildServiceImage(),
            SizedBox(width: AppSizes.spacingSmall),
            BodyText(
              label,
              size: BodySize.small,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Image.network(
          imageUrl!,
          width: AppSizes.iconSmall,
          height: AppSizes.iconSmall,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon on error
            return Icon(
              Icons.category_outlined,
              size: AppSizes.iconSmall,
              color: AppColors.textPrimary,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: AppSizes.iconSmall,
              height: AppSizes.iconSmall,
              child: Center(
                child: SizedBox(
                  width: 12.r,
                  height: 12.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Fallback icon if no image URL
    return Icon(
      icon ?? Icons.category_outlined,
      size: AppSizes.iconSmall,
      color: AppColors.textPrimary,
    );
  }
}
