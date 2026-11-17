import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../network/dio_error_mapper.dart';

/// Consistent "something went wrong" block with a friendly message and a
/// retry button. Distinguishes "you are offline" from other failures and never
/// shows a raw exception string.
class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String title;

  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.title = 'Could not load this',
  });

  @override
  Widget build(BuildContext context) {
    final offline = isOfflineError(error);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              offline ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 44.r,
              color: offline ? AppColors.textSecondary : AppColors.error,
            ),
            SizedBox(height: 10.h),
            Text(
              offline ? 'You appear to be offline' : title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              offline
                  ? 'Check your connection and try again.'
                  : userMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 14.h),
              OutlinedButton.icon(
                key: const Key('error_state_retry'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
