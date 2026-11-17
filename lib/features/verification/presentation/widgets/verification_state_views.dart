import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/artisan_verification.dart';
import '../../domain/verification_error_messages.dart';

/// Rounded tinted card used by the status views.
class _StatusCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _StatusCard({
    required this.color,
    required this.icon,
    required this.title,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22.r),
              SizedBox(width: 10.w),
              Expanded(
                child: BodyText(
                  title,
                  size: BodySize.large,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

class VerificationVerifiedView extends StatelessWidget {
  final ArtisanVerification verification;
  final VoidCallback onDone;

  const VerificationVerifiedView({
    super.key,
    required this.verification,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final last4 = verification.ninLast4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusCard(
          color: AppColors.success,
          icon: Icons.verified,
          title: "You're verified",
          children: [
            SizedBox(height: 8.h),
            BodyText(
              'Your verified badge now shows on your profile, so clients can '
              'book you with more confidence.',
              size: BodySize.medium,
              color: AppColors.textPrimary,
            ),
            if (last4 != null) ...[
              SizedBox(height: 8.h),
              BodyText(
                'NIN ending in $last4',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: BodyText(
              'Done',
              size: BodySize.medium,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class VerificationPendingView extends StatelessWidget {
  /// True once the polling budget is spent and we've stopped asking.
  final bool pollingStopped;
  final bool isChecking;
  final VoidCallback onCheckAgain;

  const VerificationPendingView({
    super.key,
    required this.pollingStopped,
    required this.isChecking,
    required this.onCheckAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusCard(
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: "We're checking your details",
          children: [
            SizedBox(height: 8.h),
            BodyText(
              pollingStopped
                  ? "This is taking longer than usual. You can leave this "
                        "screen, your verification will keep running. Tap "
                        "below to check again."
                  : 'This usually takes a few seconds. Please keep this '
                        'screen open.',
              size: BodySize.medium,
              color: AppColors.textPrimary,
            ),
            if (!pollingStopped) ...[
              SizedBox(height: 16.h),
              const LinearProgressIndicator(
                color: AppColors.warning,
                backgroundColor: AppColors.divider,
              ),
            ],
          ],
        ),
        if (pollingStopped) ...[
          SizedBox(height: 24.h),
          SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: isChecking ? null : onCheckAgain,
              child: isChecking
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : BodyText(
                      'Check again',
                      size: BodySize.medium,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Shown above the form after a `failed` outcome.
class VerificationFailureBanner extends StatelessWidget {
  final ArtisanVerification verification;

  const VerificationFailureBanner({super.key, required this.verification});

  @override
  Widget build(BuildContext context) {
    final reason = verification.failureReason;
    final remaining = verification.attemptsRemaining;
    return _StatusCard(
      color: AppColors.error,
      icon: Icons.error_outline,
      title: "We couldn't verify you",
      children: [
        SizedBox(height: 8.h),
        // Backend text, shown verbatim.
        BodyText(
          reason ?? 'The details you submitted did not match.',
          size: BodySize.medium,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.h),
        BodyText(
          remaining == 1
              ? '1 attempt left in the next ${verification.windowHours} hours'
              : '$remaining attempts left in the next '
                    '${verification.windowHours} hours',
          size: BodySize.small,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

class VerificationLockedOutView extends StatelessWidget {
  final ArtisanVerification verification;

  const VerificationLockedOutView({super.key, required this.verification});

  @override
  Widget build(BuildContext context) {
    final retryAt = verification.retryAvailableAt;
    final when = retryAt != null ? formatRetryTime(retryAt) : null;
    final reason = verification.failureReason;
    return _StatusCard(
      color: AppColors.error,
      icon: Icons.lock_clock,
      title: 'No attempts left for now',
      children: [
        SizedBox(height: 8.h),
        if (reason != null) ...[
          BodyText(reason, size: BodySize.medium, color: AppColors.textPrimary),
          SizedBox(height: 8.h),
        ],
        BodyText(
          when != null
              ? 'You can try again $when. Need it sooner? Contact support and '
                    'we can verify you manually.'
              : 'Please try again later. Need it sooner? Contact support and '
                    'we can verify you manually.',
          size: BodySize.medium,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

/// Full-screen message with a retry button. Used for load errors, with a
/// distinct look for being offline.
class VerificationMessageView extends StatelessWidget {
  final bool offline;
  final String message;
  final VoidCallback onRetry;

  const VerificationMessageView({
    super.key,
    required this.offline,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              offline ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 56.r,
              color: offline ? AppColors.textSecondary : AppColors.error,
            ),
            SizedBox(height: 16.h),
            BodyText(
              message,
              size: BodySize.medium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                ),
                child: BodyText(
                  'Retry',
                  size: BodySize.medium,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationSkeleton extends StatelessWidget {
  const VerificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double h) => Container(
      height: h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          block(90.h),
          SizedBox(height: 24.h),
          block(56.h),
          SizedBox(height: 16.h),
          block(140.h),
          SizedBox(height: 24.h),
          block(48.h),
        ],
      ),
    );
  }
}
