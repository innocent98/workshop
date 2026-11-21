import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../utils/response_time_format.dart';
import '../text/text_widgets.dart';

/// "Replies in ~12 min" with a clock icon. Renders nothing at all when the
/// artisan has no response-time data yet (`null`), so callers never need to
/// guard it and a "0" or "N/A" can never appear.
class ResponseTimeLabel extends StatelessWidget {
  final int? minutes;
  final double iconSize;

  const ResponseTimeLabel({
    super.key,
    required this.minutes,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final label = responseTimeLabel(minutes);
    if (label == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: iconSize.r,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 3.w),
        BodyText(label, size: BodySize.small, color: AppColors.textSecondary),
      ],
    );
  }
}
