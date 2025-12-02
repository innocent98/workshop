import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Reusable body text widget using Poppins font
/// 
/// This widget provides consistent styling for all body/regular text throughout the app.
/// Use different [BodySize] values to control the text size.
class BodyText extends StatelessWidget {
  final String text;
  final BodySize size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final double? height;
  final int? maxLines;
  final TextOverflow? overflow;

  const BodyText(
    this.text, {
    super.key,
    this.size = BodySize.medium,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.height,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    Color defaultColor;

    switch (size) {
      case BodySize.large:
        fontSize = AppSizes.body;
        defaultColor = AppColors.textPrimary;
        break;
      case BodySize.medium:
        fontSize = AppSizes.bodySmall;
        defaultColor = AppColors.textPrimary;
        break;
      case BodySize.small:
        fontSize = AppSizes.caption;
        defaultColor = AppColors.textSecondary;
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? defaultColor,
        height: height,
      ),
    );
  }
}

/// Body text size options
enum BodySize {
  large,
  medium,
  small,
}
