import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/completed_job.dart';

class CompletedJobCard extends StatelessWidget {
  final CompletedJob job;
  final VoidCallback? onAddToPortfolio;
  final VoidCallback? onRateClient;

  const CompletedJobCard({
    super.key,
    required this.job,
    this.onAddToPortfolio,
    this.onRateClient,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      return '${difference.inHours}hrs ago';
    } else {
      return '${difference.inDays}days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Service, Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundImage: AssetImage(job.clientAvatar),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.clientName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.service,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _getTimeAgo(job.completedDate),
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Work Image
          if (job.workImageUrl != null) ...[
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                job.workImageUrl!,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          SizedBox(height: 10.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: job.addedToPortfolio ? null : onAddToPortfolio,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    decoration: BoxDecoration(
                      color: job.addedToPortfolio
                          ? const Color(0xFFF5F5F5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: job.addedToPortfolio
                            ? const Color(0xFFE8E8E8)
                            : const Color(0xFFE8E8E8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      job.addedToPortfolio ? 'Added' : 'Add to portfolio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: job.addedToPortfolio
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: onRateClient,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Rate client',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
