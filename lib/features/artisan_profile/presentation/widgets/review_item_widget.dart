import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/review.dart';
import '../../domain/models/review_report_reason.dart';
import '../providers/report_review_provider.dart';
import 'report_review_dialog.dart';

class ReviewItemWidget extends ConsumerWidget {
  final Review review;

  const ReviewItemWidget({super.key, required this.review});

  /// Confirm, report, then tell the user what happened.
  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await showDialog<ReviewReportReason>(
      context: context,
      builder: (_) => const ReportReviewDialog(),
    );
    if (reason == null) return;

    final result = await ref
        .read(reportedReviewIdsProvider.notifier)
        .report(review.id, reason);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwnReview =
        review.customerId != null && review.customerId == currentUserId;
    final isReported = ref.watch(
      reportedReviewIdsProvider.select((ids) => ids.contains(review.id)),
    );

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      padding: EdgeInsets.all(AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: _resolveAvatar(review.reviewerAvatarUrl),
                child: review.reviewerAvatarUrl.isEmpty
                    ? Icon(Icons.person, size: 14.r)
                    : null,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      review.reviewerName,
                      size: BodySize.small,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14.r,
                          color: AppColors.textSecondary,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              BodyText(
                _formatDate(review.date),
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          BodyText(
            review.comment,
            size: BodySize.small,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          // Authors cannot report their own review (the server refuses too).
          if (!isOwnReview)
            Align(
              alignment: Alignment.centerRight,
              child: isReported
                  ? Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: const BodyText(
                        'Reported',
                        key: Key('review_reported_label'),
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : TextButton.icon(
                      key: const Key('review_report_button'),
                      onPressed: () => _report(context, ref),
                      icon: Icon(Icons.flag_outlined, size: 14.r),
                      label: const Text('Report'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _resolveAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return null;
    }
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return NetworkImage(avatarUrl);
    }
    return AssetImage(avatarUrl);
  }

  String _formatDate(DateTime date) {
    final months = [
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
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]}, ${date.year} · $hour:$minute $period';
  }
}
