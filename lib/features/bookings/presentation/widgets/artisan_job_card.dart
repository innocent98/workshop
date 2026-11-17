import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/text/text_widgets.dart';

enum ArtisanJobStatus { ongoing, next, pending, completed, cancelled }

class ArtisanJobCard extends StatelessWidget {
  final String serviceName;
  final String clientName;
  final String clientAvatar;
  final String? price;
  final String? timeInfo;
  final ArtisanJobStatus status;
  final List<String> neededServices;
  final VoidCallback? onActionPressed;
  final VoidCallback? onSecondaryActionPressed;
  final VoidCallback? onPhonePressed;
  final VoidCallback? onDirectionsPressed;
  final VoidCallback? onCardTap;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final String? statusTagLabel;
  final String? headerLabel;
  final String? headerTimeInfo;
  final String? negotiationSummary;

  const ArtisanJobCard({
    super.key,
    required this.serviceName,
    required this.clientName,
    required this.clientAvatar,
    this.price,
    this.timeInfo,
    required this.status,
    required this.neededServices,
    this.onActionPressed,
    this.onSecondaryActionPressed,
    this.onPhonePressed,
    this.onDirectionsPressed,
    this.onCardTap,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.statusTagLabel,
    this.headerLabel,
    this.headerTimeInfo,
    this.negotiationSummary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            if (_hasHeader()) _buildHeader(),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _hasHeader()
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      )
                    : BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  SizedBox(height: 8.h),
                  BodyText(
                    'Needed Service',
                    size: BodySize.small,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  ...neededServices.map(
                    (service) => _buildServiceItem(service),
                  ),
                  SizedBox(height: 12.h),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasHeader() {
    return status == ArtisanJobStatus.ongoing ||
        status == ArtisanJobStatus.next;
  }

  Color _getBackgroundColor() {
    if (status == ArtisanJobStatus.ongoing) return const Color(0xFF6B8E8E);
    if (status == ArtisanJobStatus.next) return const Color(0xFFC0C0C0);
    return const Color(0xFFF1F5F5);
  }

  Widget _buildHeader() {
    final isOngoing = status == ArtisanJobStatus.ongoing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              BodyText(
                headerLabel ?? (isOngoing ? 'ONGOING JOB' : 'NEXT JOB'),
                size: BodySize.small,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.access_time, size: 12.r, color: Colors.white),
              SizedBox(width: 4.w),
              BodyText(
                headerTimeInfo ?? (isOngoing ? 'In Progress' : 'Upcoming'),
                size: BodySize.small,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(imageUrl: clientAvatar, name: clientName, radius: 16),
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
                  Flexible(
                    child: BodyText(
                      clientName,
                      size: BodySize.small,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (status != ArtisanJobStatus.completed &&
            status != ArtisanJobStatus.cancelled)
          _buildDirectionsButton()
        else if (price != null)
          BodyText(
            price!,
            size: BodySize.small,
            fontWeight: FontWeight.w500,
            color: status == ArtisanJobStatus.completed
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
      ],
    );
  }

  Widget _buildDirectionsButton() {
    return GestureDetector(
      onTap: onDirectionsPressed,
      child: Opacity(
        opacity: onDirectionsPressed == null ? 0.55 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Icon(Icons.near_me, size: 12.r, color: AppColors.textPrimary),
              SizedBox(width: 4.w),
              BodyText(
                'Directions',
                size: BodySize.small,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (status == ArtisanJobStatus.completed ||
        status == ArtisanJobStatus.cancelled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusTag(),
          SizedBox(height: 8.h),
          if (timeInfo != null)
            BodyText(
              timeInfo!,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBCCBCB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: BodyText(
                primaryActionLabel ?? 'View Receipt',
                size: BodySize.medium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (status == ArtisanJobStatus.pending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusTag(
            label: 'Scheduled',
            color: const Color(0xFFBCCBCB),
            textColor: AppColors.primary,
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onCardTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE9D7B6)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 13.r,
                    color: const Color(0xFF8A5A00),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      negotiationSummary ?? 'Tap to open and negotiate price.',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF8A5A00),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondaryActionPressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFE2725B),
                      width: 1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: BodyText(
                    secondaryActionLabel ?? 'Reject',
                    size: BodySize.medium,
                    color: const Color(0xFFE2725B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: onActionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: BodyText(
                      primaryActionLabel ?? 'Accept',
                      size: BodySize.medium,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
              minimumSize: Size(double.infinity, 40.h),
              padding: EdgeInsets.zero,
            ),
            child: BodyText(
              primaryActionLabel ??
                  (status == ArtisanJobStatus.ongoing
                      ? 'Continue Job'
                      : 'Start Job'),
              size: BodySize.medium,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        if (onPhonePressed != null) ...[
          _buildIconButton(Icons.phone_outlined, onPhonePressed),
        ],
      ],
    );
  }

  Widget _buildStatusTag({String? label, Color? color, Color? textColor}) {
    String tagLabel =
        label ??
        statusTagLabel ??
        (status == ArtisanJobStatus.completed ? 'Completed' : 'Cancelled');
    Color tagColor =
        color ??
        (status == ArtisanJobStatus.completed
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE));
    Color tagTextColor =
        textColor ??
        (status == ArtisanJobStatus.completed ? Colors.green : Colors.red);
    IconData? icon = status == ArtisanJobStatus.completed
        ? Icons.check_circle
        : (status == ArtisanJobStatus.cancelled ? Icons.cancel : null);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.r, color: tagTextColor),
            SizedBox(width: 4.w),
          ],
          BodyText(
            tagLabel,
            size: BodySize.small,
            color: tagTextColor,
            fontWeight: FontWeight.bold,
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
