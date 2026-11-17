import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Visual-only checkbox for the service picker rows (the row owns the tap).
/// Unchecked is an empty outlined box; checked is solid teal with a tick.
class ServiceCheckbox extends StatelessWidget {
  final bool selected;

  const ServiceCheckbox({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textTertiary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: selected
            ? Icon(Icons.check, size: 16.r, color: Colors.white)
            : null,
      ),
    );
  }
}
