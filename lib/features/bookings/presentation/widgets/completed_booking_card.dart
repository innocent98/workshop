import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import 'package:workchop/features/bookings/domain/models/booking.dart';

class CompletedBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onRateTap;
  final bool isReviewSubmitted;
  final bool isSubmittingReview;
  final String secondaryActionLabel;

  const CompletedBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onDeleteTap,
    this.onRateTap,
    this.isReviewSubmitted = false,
    this.isSubmittingReview = false,
    this.secondaryActionLabel = 'Delete Job',
  });

  String _formatDateTime(DateTime dateTime) {
    final dayFormat = DateFormat('EEEE, d MMM, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dayFormat.format(dateTime)} · ${timeFormat.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  backgroundImage: _resolveImageProvider(booking.artisanAvatar),
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
                            Icon(Icons.verified, size: 14.r, color: Colors.red),
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
                  onPressed: onTap,
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
            ...booking.services.map(
              (service) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 16.r, color: AppColors.primary),
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
              ),
            ),

            SizedBox(height: AppSizes.spacing),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDeleteTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Center(
                        child: BodyText(
                          secondaryActionLabel,
                          size: BodySize.tiny,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onRateTap != null) ...[
                  SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: GestureDetector(
                      onTap: isReviewSubmitted || isSubmittingReview
                          ? null
                          : onRateTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isReviewSubmitted
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        child: Center(
                          child: BodyText(
                            isSubmittingReview
                                ? 'Submitting...'
                                : (isReviewSubmitted
                                      ? 'Reviewed'
                                      : 'Rate Artisan'),
                            size: BodySize.tiny,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _resolveImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }
    return AssetImage(imageUrl);
  }
}
