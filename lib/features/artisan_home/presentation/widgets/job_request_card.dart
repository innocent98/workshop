import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../bookings/domain/models/artisan_booking.dart';

class JobRequestCard extends StatelessWidget {
  final ArtisanBooking booking;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onNegotiate;
  final VoidCallback? onDecline;
  final VoidCallback? onCall;

  const JobRequestCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onAccept,
    this.onNegotiate,
    this.onDecline,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final service = booking.serviceName ?? 'Service Request';
    final clientName = booking.customerName ?? 'Client';

    final neededServices = <String>[];
    if ((booking.jobDescription ?? '').trim().isNotEmpty) {
      neededServices.add(booking.jobDescription!.trim());
    }

    return GestureDetector(
      onTap: onTap ?? () => context.push(AppRoutes.jobDetail, extra: booking),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
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
                    backgroundImage: _getAvatarImage(
                      booking.customerProfilePictureUrl ??
                          'assets/images/regular.jpg',
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyText(
                          service,
                          size: BodySize.medium,
                          fontWeight: FontWeight.w500,
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
                  BodyText(
                    _formatBudget(booking),
                    size: BodySize.small,
                    fontWeight: FontWeight.w500,
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
              if (neededServices.isEmpty)
                _buildListItem('No extra details provided')
              else
                ...neededServices.map(_buildListItem),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
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
                  if (onCall != null &&
                      booking.status != ArtisanBookingStatus.pending)
                    GestureDetector(
                      onTap: onCall,
                      child: Icon(
                        Icons.phone_outlined,
                        size: 18.r,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              BodyText(
                _formatDateTime(booking.jobDate),
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38.h,
                      child: OutlinedButton(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCFD8D8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SizedBox(
                      height: 38.h,
                      child: OutlinedButton(
                        onPressed: onNegotiate,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBCCBCB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Negotiate',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onAccept,
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: BodyText(
                          'Accept',
                          size: BodySize.small,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  ImageProvider _getAvatarImage(String avatar) {
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return NetworkImage(avatar);
    }
    return AssetImage(avatar);
  }

  String _formatBudget(ArtisanBooking booking) {
    if (booking.agreedAmount != null) {
      return '₦${booking.agreedAmount!.toStringAsFixed(0)}';
    }
    return '₦${booking.budgetMin.toStringAsFixed(0)} - ₦${booking.budgetMax.toStringAsFixed(0)}';
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[local.weekday - 1]}, ${local.day} ${months[local.month - 1]}, ${local.year} • $hour:$minute $period';
  }
}
