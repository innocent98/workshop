import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/service_category.dart';

class ServiceCategoryListItem extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback? onTap;

  const ServiceCategoryListItem({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacing),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing,
          vertical: AppSizes.spacing + 2.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          children: [
            // Category Icon
            Icon(
              category.icon,
              size: AppSizes.iconSize,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: AppSizes.spacing),

            // Category Name
            BodyText(
              category.name,
              size: BodySize.medium,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
