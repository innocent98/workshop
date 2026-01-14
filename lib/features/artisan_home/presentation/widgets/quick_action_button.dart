import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final Widget? trailing;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.isPrimary = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: trailing == null ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE2725B) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14.r,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: isPrimary ? Colors.white : AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: 6.w),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
