import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/common/verified_badge.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import 'package:workchop/features/bookings/domain/models/booking.dart';

class OngoingBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onRateTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onCallTap;

  const OngoingBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onRateTap,
    this.onChatTap,
    this.onCallTap,
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
                ProfileAvatar(
                  imageUrl: booking.artisanAvatar,
                  name: booking.artisanName,
                  radius: 16,
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
                          if (booking.isVerified) const VerifiedBadge(),
                          BodyText(
                            booking.serviceType,
                            size: BodySize.small,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      // Accepted date
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 12.r,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Accepted: ${_formatDateTime(booking.dateTime)}',
                              style: TextStyle(fontSize: 9.sp),
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
            if (booking.isDisputed) ...[
              SizedBox(height: AppSizes.spacingSmall),
              _DisputedBanner(reason: booking.disputeReason),
            ],
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
                if (onRateTap != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onRateTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        child: const Center(
                          child: BodyText(
                            'Rate Artisan',
                            size: BodySize.small,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onChatTap != null) ...[
                  if (onRateTap != null) SizedBox(width: AppSizes.spacingSmall),
                  GestureDetector(
                    onTap: onChatTap,
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 20.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (onCallTap != null) ...[
                  SizedBox(width: AppSizes.spacingSmall),
                  GestureDetector(
                    onTap: onCallTap,
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        size: 20.r,
                        color: Colors.white,
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
}

class _DisputedBanner extends StatelessWidget {
  final String? reason;

  const _DisputedBanner({this.reason});

  @override
  Widget build(BuildContext context) {
    final text = (reason ?? '').trim();
    return Container(
      key: const Key('disputed_banner'),
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_gmailerrorred, size: 16.r, color: AppColors.error),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodyText(
                  'Disputed',
                  size: BodySize.small,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
                if (text.isNotEmpty)
                  BodyText(
                    text,
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
