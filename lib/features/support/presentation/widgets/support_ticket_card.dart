import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/support_ticket.dart';

class SupportTicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback? onTap;

  const SupportTicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}hrs ago';
    } else {
      return '${difference.inDays}days ago';
    }
  }

  String _getFormattedTime(DateTime dateTime) {
    return DateFormat('HH:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            BodyText(
              ticket.title,
              size: BodySize.small,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 4.h),
            // Metadata
            Row(
              children: [
                // Ticket icon
                Container(
                  width: 12.r,
                  height: 12.r,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 6.w),
                // Ticket label and time
                Text(
                  'Ticket: ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Submitted ${_getTimeAgo(ticket.submittedAt)} • ${_getFormattedTime(ticket.submittedAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
