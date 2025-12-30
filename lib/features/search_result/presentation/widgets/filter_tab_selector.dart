import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';

enum FilterTab { all, artisans, stores }

class FilterTabSelector extends StatelessWidget {
  final FilterTab selectedTab;
  final ValueChanged<FilterTab> onTabChanged;

  const FilterTabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'All',
            isActive: selectedTab == FilterTab.all,
            onTap: () => onTabChanged(FilterTab.all),
          ),
          SizedBox(width: 4.w),
          _TabButton(
            label: 'Artisans',
            isActive: selectedTab == FilterTab.artisans,
            onTap: () => onTabChanged(FilterTab.artisans),
          ),
          SizedBox(width: 4.w),
          _TabButton(
            label: 'Stores',
            isActive: selectedTab == FilterTab.stores,
            onTap: () => onTabChanged(FilterTab.stores),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Center(
            child: BodyText(
              label,
              size: BodySize.small,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
