import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class RatingDistribution extends StatelessWidget {
  final Map<int, double> distribution;

  const RatingDistribution({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    // No reviews counted yet: bars would all read 0% next to a non-zero
    // average, so show nothing.
    if (distribution.values.every((value) => value <= 0)) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        _buildRatingBar(5, distribution[5] ?? 0),
        SizedBox(height: 4.h),
        _buildRatingBar(4, distribution[4] ?? 0),
        SizedBox(height: 4.h),
        _buildRatingBar(3, distribution[3] ?? 0),
        SizedBox(height: 4.h),
        _buildRatingBar(2, distribution[2] ?? 0),
        SizedBox(height: 4.h),
        _buildRatingBar(1, distribution[1] ?? 0),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        BodyText(
          '$stars',
          size: BodySize.small,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6.h,
            ),
          ),
        ),
        SizedBox(width: AppSizes.spacingSmall),
        BodyText(
          '${percentage.toInt()}%',
          size: BodySize.small,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }
}
