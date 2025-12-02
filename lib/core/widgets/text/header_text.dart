import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Reusable header text widget using Bricolage Grotesque font
/// 
/// This widget provides consistent styling for all header text throughout the app.
/// Use different [HeaderSize] values to control the text size.
class HeaderText extends StatelessWidget {
  final String text;
  final HeaderSize size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;

  const HeaderText(
    this.text, {
    super.key,
    this.size = HeaderSize.h2,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    FontWeight defaultWeight;

    switch (size) {
      case HeaderSize.h1:
        fontSize = AppSizes.h1;
        defaultWeight = FontWeight.bold;
        break;
      case HeaderSize.h2:
        fontSize = AppSizes.h2;
        defaultWeight = FontWeight.bold;
        break;
      case HeaderSize.h3:
        fontSize = AppSizes.h3;
        defaultWeight = FontWeight.w600;
        break;
      case HeaderSize.h4:
        fontSize = AppSizes.h4;
        defaultWeight = FontWeight.w600;
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.bricolageGrotesque(
        fontSize: fontSize,
        fontWeight: fontWeight ?? defaultWeight,
        color: color ?? AppColors.textPrimary,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

/// Header text size options
enum HeaderSize {
  h1,
  h2,
  h3,
  h4,
}
