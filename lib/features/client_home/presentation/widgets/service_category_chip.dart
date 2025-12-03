import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/service_category.dart';

class ServiceCategoryChip extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback? onTap;

  const ServiceCategoryChip({
    super.key,
    required this.category,
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
            Icon(
              category.icon,
              size: AppSizes.iconSmall,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: AppSizes.spacingSmall),
            BodyText(
              category.name,
              size: BodySize.small,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
