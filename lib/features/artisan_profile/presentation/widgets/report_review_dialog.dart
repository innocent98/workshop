import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/review_report_reason.dart';

/// Confirmation step before reporting a review. Pops with the chosen
/// [ReviewReportReason], or null when cancelled. Confirm stays disabled until
/// a reason is picked.
class ReportReviewDialog extends StatefulWidget {
  const ReportReviewDialog({super.key});

  @override
  State<ReportReviewDialog> createState() => _ReportReviewDialogState();
}

class _ReportReviewDialogState extends State<ReportReviewDialog> {
  ReviewReportReason? _reason;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report this review?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BodyText(
              'Tell us what is wrong. Our team will take a look. The review '
              'stays visible until a moderator decides.',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            for (final reason in ReviewReportReason.values)
              ListTile(
                key: Key('report_reason_${reason.apiValue}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(reason.label),
                trailing: Icon(
                  _reason == reason
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _reason == reason
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                onTap: () => setState(() => _reason = reason),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('report_review_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('report_review_confirm'),
          onPressed: _reason == null
              ? null
              : () => Navigator.of(context).pop(_reason),
          child: const Text('Report'),
        ),
      ],
    );
  }
}
