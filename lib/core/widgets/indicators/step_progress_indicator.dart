import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color completedColor;
  final Color inactiveColor;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = const Color(0xFFE2725B), // Coral color for current step
    this.completedColor = const Color(0xFF008080), // Teal/primary color for completed steps
    this.inactiveColor = const Color(0xFFD0D0D0), // Light gray for future steps
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber == currentStep;
        final isCompleted = stepNumber < currentStep;

        if (isActive) {
          // Current step - coral pill/oval shape with number
          return Container(
            height: 20.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6.w : 0),
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (isCompleted) {
          // Completed step - teal/green circle
          return Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6.w : 0),
            decoration: BoxDecoration(
              color: completedColor,
              shape: BoxShape.circle,
            ),
          );
        } else {
          // Future step - gray circle
          return Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6.w : 0),
            decoration: BoxDecoration(
              color: inactiveColor,
              shape: BoxShape.circle,
            ),
          );
        }
      }),
    );
  }
}
