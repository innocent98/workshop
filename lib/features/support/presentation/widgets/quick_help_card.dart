import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/models/quick_help.dart';

class QuickHelpCard extends StatelessWidget {
  final QuickHelp quickHelp;
  final VoidCallback? onTap;

  const QuickHelpCard({
    super.key,
    required this.quickHelp,
    this.onTap,
  });

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: _parseColor(quickHelp.backgroundColor),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              quickHelp.title,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            // CTA
            Row(
              children: [
                Text(
                  quickHelp.ctaText,
                  style: TextStyle(
                    fontSize: AppSizes.caption,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward,
                  size: 16.r,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
