import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/blog_post.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback? onTap;

  const BlogPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260.w,
        margin: EdgeInsets.only(right: AppSizes.spacing),
        padding: EdgeInsets.all(AppSizes.spacing + 4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            BodyText(
              post.title,
              size: BodySize.medium,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.spacingSmall + 4.h),

            // Read time
            Row(
              children: [
                BodyText(
                  '${post.readTimeMinutes} mins read',
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Icon(
                  Icons.arrow_forward,
                  size: 14.r,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
