import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/verification_status.dart';

/// Label, colour and icon for each [VerificationStatus].
class VerificationStatusStyle {
  final String label;
  final String hint;
  final Color color;
  final IconData icon;

  const VerificationStatusStyle._(this.label, this.hint, this.color, this.icon);

  static VerificationStatusStyle of(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return const VerificationStatusStyle._(
          'Verified',
          'Your identity is confirmed',
          AppColors.success,
          Icons.verified,
        );
      case VerificationStatus.pending:
        return const VerificationStatusStyle._(
          'In review',
          "We're checking your details",
          AppColors.warning,
          Icons.hourglass_top_rounded,
        );
      case VerificationStatus.failed:
        return const VerificationStatusStyle._(
          'Needs attention',
          "We couldn't verify you. Tap to try again",
          AppColors.error,
          Icons.error_outline,
        );
      case VerificationStatus.unverified:
      case VerificationStatus.unknown:
        return const VerificationStatusStyle._(
          'Not verified',
          'Get the verified badge and win more trust',
          AppColors.textSecondary,
          Icons.shield_outlined,
        );
    }
  }
}

/// Small pill showing the verification status.
class VerificationStatusChip extends StatelessWidget {
  final VerificationStatus status;

  const VerificationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = VerificationStatusStyle.of(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14.r, color: style.color),
          SizedBox(width: 4.w),
          BodyText(
            style.label,
            size: BodySize.small,
            color: style.color,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

/// Row for the artisan's own profile page: status badge that opens the
/// verification screen.
class VerificationStatusTile extends StatelessWidget {
  final VerificationStatus status;
  final VoidCallback onTap;

  const VerificationStatusTile({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = VerificationStatusStyle.of(status);
    return Semantics(
      button: true,
      label: 'Identity verification, ${style.label}',
      excludeSemantics: true,
      child: ListTile(
        minTileHeight: 56.h,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        title: Row(
          children: [
            Flexible(
              child: BodyText(
                'Identity verification',
                size: BodySize.medium,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            VerificationStatusChip(status: status),
          ],
        ),
        subtitle: BodyText(
          style.hint,
          size: BodySize.small,
          color: AppColors.textSecondary,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.r,
          color: AppColors.textPrimary,
        ),
        onTap: onTap,
      ),
    );
  }
}
