import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class SearchSuggestionItem extends StatelessWidget {
  final String text;
  final bool isHistory;
  final VoidCallback onTap;

  const SearchSuggestionItem({
    super.key,
    required this.text,
    required this.isHistory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacingSmall + 4.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: isHistory ? const Color(0xFFE0F2F1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          children: [
            Icon(
              isHistory ? Icons.access_time : Icons.search,
              size: AppSizes.iconSize,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppSizes.spacing),
            Expanded(
              child: BodyText(
                text,
                size: BodySize.large,
                color: AppColors.textPrimary,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 20.r,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
