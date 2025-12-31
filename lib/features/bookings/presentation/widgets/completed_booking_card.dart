import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/booking.dart';

class CompletedBookingCard extends StatelessWidget {
  final Booking booking;

  const CompletedBookingCard({
    super.key,
    required this.booking,
  });

  String _formatDateTime(DateTime dateTime) {
    final dayFormat = DateFormat('EEEE, d MMM, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dayFormat.format(dateTime)} · ${timeFormat.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacing),
      padding: EdgeInsets.all(AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Service Type, Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: AssetImage(booking.artisanAvatar),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with verified badge and service type
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 2.w,
                      children: [
                        BodyText(
                          booking.artisanName,
                          size: BodySize.small,
                          fontWeight: FontWeight.w600,
                        ),
                        if (booking.isVerified)
                          Icon(
                            Icons.verified,
                            size: 14.r,
                            color: Colors.red,
                          ),
                        BodyText(
                          booking.serviceType,
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Completed date
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12.r,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'Completed: ${_formatDateTime(booking.dateTime)}',
                            style: TextStyle(fontSize: 8.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 18.r,
                  color: AppColors.textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // TODO: Show menu
                },
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),

          // Needed Service
          const BodyText(
            'Needed Service',
            size: BodySize.small,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: AppSizes.spacingSmall),

          // Services list
          ...booking.services.map((service) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check,
                      size: 16.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: BodyText(
                        service,
                        size: BodySize.small,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),

          SizedBox(height: AppSizes.spacing),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Delete job
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: const Center(
                      child: BodyText(
                        'Delete Job',
                        size: BodySize.small,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spacing),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Rate artisan
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: const Center(
                      child: BodyText(
                        'Rate Artisan',
                        size: BodySize.small,
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
