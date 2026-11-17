import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/payment_verification.dart';

/// Banner shown above the bookings list while a Paystack payment is awaiting
/// confirmation. It never claims success: it only shows progress or offers a
/// manual re-check. Success is announced separately once the backend confirms.
class PendingPaymentBanner extends StatelessWidget {
  final PendingPayment payment;
  final VoidCallback onCheckAgain;
  final VoidCallback onDismiss;

  const PendingPaymentBanner({
    super.key,
    required this.payment,
    required this.onCheckAgain,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final verifying = payment.phase == PendingPaymentPhase.verifying;
    final unconfirmed = payment.phase == PendingPaymentPhase.unconfirmed;

    final title = verifying ? 'Confirming payment...' : 'Payment not confirmed';
    final body = switch (payment.phase) {
      PendingPaymentPhase.verifying =>
        payment.totalAttempts > 1
            ? 'Checking with the bank (attempt ${payment.attempt} of '
                  '${payment.totalAttempts}). Please keep the app open.'
            : 'Checking with the bank. Please keep the app open.',
      PendingPaymentPhase.unconfirmed =>
        'We have not received confirmation yet. Card and transfer payments can '
            'take a minute. If you have paid, check again.',
      PendingPaymentPhase.awaitingReturn =>
        'Finish paying in your browser, then come back here. If you already '
            'paid, check again.',
    };

    return Semantics(
      container: true,
      liveRegion: true,
      label: title,
      child: Container(
        key: const Key('pending_payment_banner'),
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: unconfirmed
              ? const Color(0xFFFFF6E5)
              : const Color(0xFFE6F4F4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (verifying)
                  SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    unconfirmed ? Icons.schedule : Icons.open_in_browser,
                    size: 18.r,
                    color: unconfirmed
                        ? const Color(0xFF8A5A00)
                        : AppColors.primary,
                  ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              body,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            if (!verifying) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const Key('pending_payment_check_again'),
                      onPressed: onCheckAgain,
                      child: const Text("I've paid, check again"),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    key: const Key('pending_payment_dismiss'),
                    onPressed: onDismiss,
                    child: const Text("I didn't pay"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
