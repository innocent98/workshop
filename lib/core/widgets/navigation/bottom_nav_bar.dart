import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isArtisan;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isArtisan = false,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(
        activeIconPath: 'assets/icons/home_icon_a.png',
        inactiveIconPath: 'assets/icons/home_icon_a.png',
        label: 'Home',
        isActive: currentIndex == 0,
        onTap: () => onTap(0),
      ),
      _NavItem(
        activeIconPath: isArtisan ? 'assets/icons/job_icon_a.png' : 'assets/icons/bookings_icon_a.png',
        inactiveIconPath: isArtisan ? 'assets/icons/job_icon_i.png' : 'assets/icons/bookings_icon_i.png',
        label: isArtisan ? 'Jobs' : 'Bookings',
        isActive: currentIndex == 1,
        onTap: () => onTap(1),
      ),
      if (isArtisan)
        _NavItem(
          activeIconPath: 'assets/icons/wallet_icon_a.png', // Assuming this exists or using fallback
          inactiveIconPath: 'assets/icons/wallet_icon_i.png',
          label: 'Earnings',
          isActive: currentIndex == 2,
          onTap: () => onTap(2),
        ),
      _NavItem(
        activeIconPath: 'assets/icons/support_icon_a.png',
        inactiveIconPath: 'assets/icons/support_icon_i.png',
        label: 'Support',
        isActive: currentIndex == (isArtisan ? 3 : 2),
        onTap: () => onTap(isArtisan ? 3 : 2),
      ),
      _NavItem(
        activeIconPath: 'assets/icons/profile_icon_i.png',
        inactiveIconPath: 'assets/icons/profile_icon_i.png',
        label: 'Profile',
        isActive: currentIndex == (isArtisan ? 4 : 3),
        onTap: () => onTap(isArtisan ? 4 : 3),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String activeIconPath;
  final String inactiveIconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.activeIconPath,
    required this.inactiveIconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isActive ? activeIconPath : inactiveIconPath,
              width: 24.r,
              height: 24.r,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
