import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../bookings/domain/models/artisan_booking.dart';

class OngoingJobCard extends StatelessWidget {
  final ArtisanBooking booking;
  final VoidCallback? onCall;

  const OngoingJobCard({super.key, required this.booking, this.onCall});

  @override
  Widget build(BuildContext context) {
    final clientAvatar = booking.customerProfilePictureUrl ?? '';
    final serviceName = booking.serviceName ?? 'Service Request';
    final clientName = booking.customerName ?? 'Client';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.jobDetail, extra: booking),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E8E),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        BodyText(
                          'ONGOING JOB',
                          size: BodySize.small,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12.r, color: Colors.white),
                      SizedBox(width: 4.w),
                      BodyText(
                        'In progress',
                        size: BodySize.small,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatar(
                        imageUrl: clientAvatar,
                        name: clientName,
                        radius: 16,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyText(
                              serviceName,
                              size: BodySize.medium,
                              fontWeight: FontWeight.normal,
                            ),
                            Row(
                              children: [
                                BodyText(
                                  'Client: ',
                                  size: BodySize.small,
                                  color: AppColors.textSecondary,
                                ),
                                Expanded(
                                  child: BodyText(
                                    clientName,
                                    size: BodySize.small,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F5),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 12.r,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: 4.w),
                            BodyText(
                              'Directions',
                              size: BodySize.small,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  BodyText(
                    'Needed Service',
                    size: BodySize.small,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  _buildServiceItem(
                    (booking.jobDescription ?? '').trim().isEmpty
                        ? 'No additional details provided'
                        : booking.jobDescription!.trim(),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push(AppRoutes.jobDetail, extra: booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            minimumSize: Size(double.infinity, 40.h),
                          ),
                          child: BodyText(
                            'Continue Job',
                            size: BodySize.medium,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (onCall != null) ...[
                        SizedBox(width: 8.w),
                        _buildIconButton(Icons.phone_outlined, onCall),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(Icons.check, size: 12.r, color: AppColors.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: BodyText(
              text,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: const Color(0xFFBCCBCB),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18.r),
      ),
    );
  }
}
