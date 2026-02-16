import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  bool get _isNetworkImage {
    final uri = Uri.tryParse(imagePath);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _buildServiceImage() {
    if (imagePath.isEmpty) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Icon(
          Icons.handyman_outlined,
          color: AppColors.textSecondary,
          size: 30.r,
        ),
      );
    }

    if (_isNetworkImage) {
      return Image.network(
        imagePath,
        height: 100.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
              size: 30.r,
            ),
          );
        },
      );
    }

    return Image.asset(
      imagePath,
      height: 100.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: 30.r,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8), // Light gray background
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          children: [
            // Card Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Service Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: _buildServiceImage(),
                  ),
                  SizedBox(height: 8.h),

                  // Service Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator (Top Right)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE2725B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE2725B)
                        : const Color(0xFFD0D0D0),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 18.r)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
