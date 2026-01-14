import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/support_category.dart';

class SupportCategoryCard extends StatelessWidget {
  final SupportCategory category;
  final VoidCallback? onTap;

  const SupportCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular icon container
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Image.asset(
                category.iconPath,
                width: 22.r,
                height: 22.r,
                fit: BoxFit.contain,
                color: AppColors.primary,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          // Title
          Text(
            category.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
