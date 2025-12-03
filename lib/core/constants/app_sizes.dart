import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive size constants using flutter_screenutil
class AppSizes {
  AppSizes._();

  // Font Sizes (responsive)
  static double get h1 => 32.sp;
  static double get h2 => 28.sp;
  static double get h3 => 24.sp;
  static double get h4 => 20.sp;
  static double get body => 16.sp;
  static double get bodySmall => 14.sp;
  static double get caption => 12.sp;

  // Component Sizes
  static double get buttonHeight => 48.h;
  static double get inputHeight => 56.h;
  static double get iconSize => 24.r;
  static double get iconSmall => 20.r;
  static double get iconLarge => 32.r;

  // Spacing
  static double get spacing => 16.w;
  static double get spacingSmall => 8.w;
  static double get spacingLarge => 24.w;

  // Border Radius
  static double get radius => 12.r;
  static double get radiusSmall => 8.r;
  static double get radiusLarge => 16.r;

  // Elevation
  static double get elevation => 4;
}
