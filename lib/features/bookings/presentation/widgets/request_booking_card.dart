import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/common/verified_badge.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import 'package:workchop/features/bookings/domain/models/booking.dart';

class RequestBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onUpdateTap;
  final String? secondaryActionLabel;
  final String? primaryActionLabel;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onCallTap;

  const RequestBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancelTap,
    this.onUpdateTap,
    this.secondaryActionLabel,
    this.primaryActionLabel,
    this.onSecondaryTap,
    this.onPrimaryTap,
    this.onCallTap,
  });

  /// A 0 - 0 range means the client did not set a budget, so show nothing.
  bool get _hasBudget {
    final min = booking.budgetMin;
    final max = booking.budgetMax;
    return min != null && max != null && max > 0;
  }

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
                            color: AppColors.textPrimary,
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
                      // Booked date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12.r,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Booked: ${_formatDateTime(booking.dateTime)}',
                              style: TextStyle(fontSize: 9.sp),
                              // color: AppColors.textSecondary,
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

            if (_hasBudget) ...[
              SizedBox(height: 4.h),
              Row(
                key: const Key('request_card_budget'),
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 16.r,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  const BodyText(
                    'Budget: ',
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                  ),
                  Flexible(
                    child: BodyText(
                      formatNairaRange(booking.budgetMin!, booking.budgetMax!),
                      size: BodySize.small,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: AppSizes.spacing),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSecondaryTap ?? onCancelTap,
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
                          (secondaryActionLabel ?? 'Cancel Request'),
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
                    onTap: onPrimaryTap ?? onUpdateTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Center(
                        child: BodyText(
                          (primaryActionLabel ?? 'Update Request'),
                          size: BodySize.small,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
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
