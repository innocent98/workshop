import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class StoreCard extends StatelessWidget {
  final String name;
  final String proprietor;
  final String description;
  final String rating;
  final String distance;
  final String imagePath;

  const StoreCard({
    super.key,
    required this.name,
    required this.proprietor,
    required this.description,
    required this.rating,
    required this.distance,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140.h, // Reduced height for more compact look
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14.r,
                      backgroundImage: const AssetImage('assets/images/regular.jpg'),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyText(name, size: BodySize.medium, fontWeight: FontWeight.bold),
                          BodyText(proprietor, size: BodySize.small, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Expanded(
                  child: BodyText(
                    description,
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 10.r, color: Colors.amber),
                    SizedBox(width: 4.w),
                    BodyText(rating, size: BodySize.small, fontWeight: FontWeight.bold),
                    const Spacer(),
                    Icon(Icons.location_on, size: 10.r, color: AppColors.textTertiary),
                    SizedBox(width: 4.w),
                    BodyText(distance, size: BodySize.small, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 80.w, // Reduced image size
              height: 80.h,
              child: Image.network(
                'https://picsum.photos/200',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
