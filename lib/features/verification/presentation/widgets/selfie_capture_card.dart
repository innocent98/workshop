import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';

/// Shows the captured selfie (or a prompt to take one) with a take/retake
/// action. The file stays in the parent's state only until it is uploaded.
class SelfieCaptureCard extends StatelessWidget {
  final File? selfie;
  final bool enabled;
  final VoidCallback onCapture;

  const SelfieCaptureCard({
    super.key,
    required this.selfie,
    required this.enabled,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final file = selfie;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: file == null
              ? 'No selfie taken yet'
              : 'Selfie preview. Double tap the retake button to take a new one',
          image: true,
          child: Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.face_retouching_natural,
                        size: 56.r,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 8.h),
                      BodyText(
                        'Take a clear selfie in good light',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  )
                : Image.file(
                    file,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 48.h,
          child: OutlinedButton.icon(
            onPressed: enabled ? onCapture : null,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
            ),
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            label: BodyText(
              file == null ? 'Take selfie' : 'Retake selfie',
              size: BodySize.medium,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
