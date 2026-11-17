import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// The one verified-artisan mark used across the app so it always reads the
/// same colour (success green).
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified',
      child: Icon(Icons.verified, size: size.r, color: AppColors.success),
    );
  }
}
