import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subText;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subText,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyText(
            label,
            size: BodySize.small,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 4.h),
          HeaderText(
            value,
            size: HeaderSize.h4,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          if (subText != null) ...[
            SizedBox(height: 2.h),
            BodyText(
              subText!,
              size: BodySize.small,
              color: const Color(0xFFE2725B),
              fontWeight: FontWeight.w500,
            ),
          ],
        ],
      ),
    );
  }
}
