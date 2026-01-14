import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/faq.dart';

class FAQItem extends StatelessWidget {
  final FAQ faq;
  final VoidCallback? onTap;

  const FAQItem({
    super.key,
    required this.faq,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: BodyText(
                faq.question,
                size: BodySize.small,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              size: 20.r,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
