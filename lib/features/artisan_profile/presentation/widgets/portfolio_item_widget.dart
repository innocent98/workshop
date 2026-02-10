import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/portfolio_item.dart';

class PortfolioItemWidget extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback? onTap;

  const PortfolioItemWidget({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: _buildPortfolioImage(),
          ),
          SizedBox(height: AppSizes.spacingSmall),
          BodyText(
            item.title,
            size: BodySize.small,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioImage() {
    if (item.imageUrl.startsWith('http://') ||
        item.imageUrl.startsWith('https://')) {
      return Image.network(
        item.imageUrl,
        gaplessPlayback: true,
        width: double.infinity,
        height: 140.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }

    return Image.asset(
      item.imageUrl,
      width: double.infinity,
      height: 140.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: double.infinity,
      height: 140.h,
      color: const Color(0xFFF1F5F9),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: 24.r,
      ),
    );
  }
}
