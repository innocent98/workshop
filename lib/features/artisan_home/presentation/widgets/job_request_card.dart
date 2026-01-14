import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/job_request.dart';

class JobRequestCard extends StatelessWidget {
  final JobRequest job;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const JobRequestCard({
    super.key,
    required this.job,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.85.sw,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: AssetImage(job.clientAvatar),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(job.service, size: BodySize.medium, fontWeight: FontWeight.w500),
                    Row(
                      children: [
                        BodyText('Client: ', size: BodySize.small, color: AppColors.textSecondary),
                        BodyText(job.clientName, size: BodySize.small, fontWeight: FontWeight.w500),
                        SizedBox(width: 4.w),
                        Icon(Icons.check_circle, size: 10.r, color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              BodyText(
                'N5k - N7k',
                size: BodySize.small,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          BodyText('Needed Service', size: BodySize.small, fontWeight: FontWeight.w500),
          SizedBox(height: 4.h),
          _buildListItem('Door and Window Casing Installation'),
          _buildListItem('Hardware Installation (Hinges, Drawer Slides, Lo...'),
          _buildListItem('Advanced Wood Joinery'),
          SizedBox(height: 10.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFBCCBCB),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: BodyText(
                  'Scheduled',
                  size: BodySize.small,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              BodyText(
                '${job.distance}km away',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          BodyText(
            'Saturday, 27 Nov, 2025 • 07:25 AM',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.jobDetail, extra: job),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBCCBCB),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: BodyText('View Details', size: BodySize.medium, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: BodyText('Accept', size: BodySize.medium, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(Icons.check, size: 10.r, color: AppColors.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: BodyText(
              text,
              size: BodySize.small,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
