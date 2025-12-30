import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/review.dart';

class ReviewItemWidget extends StatelessWidget {
  final Review review;

  const ReviewItemWidget({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      padding: EdgeInsets.all(AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: AssetImage(review.reviewerAvatarUrl),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      review.reviewerName,
                      size: BodySize.small,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14.r,
                          color: AppColors.textSecondary,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              BodyText(
                _formatDate(review.date),
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          BodyText(
            review.comment,
            size: BodySize.small,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]}, ${date.year} · $hour:$minute $period';
  }
}
