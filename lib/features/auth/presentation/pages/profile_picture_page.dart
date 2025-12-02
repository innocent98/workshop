import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/indicators/step_progress_indicator.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';

class ProfilePicturePage extends StatefulWidget {
  final UserType userType;

  const ProfilePicturePage({
    super.key,
    required this.userType,
  });

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final _bioController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isBioFocused = false;
  final _bioFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bioFocusNode.addListener(() {
      setState(() {
        _isBioFocused = _bioFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();

      if (status.isGranted) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1080,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      } else if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take pictures'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Camera permission is permanently denied. Please enable it in settings.'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take picture: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadPicture() async {
    try {
      // Using pickImage with gallery source which uses the Android Photo Picker on Android 13+
      // This doesn't require storage permissions
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload picture: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleContinue() {
    // TODO: Save profile picture and bio, then complete registration
    print('Profile picture: ${_selectedImage?.path}');
    print('Bio: ${_bioController.text}');
    // Navigate to home or completion screen
    // context.push(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.userType == UserType.artisan
        ? 'Set your profile picture to help clients recognize you.'
        : 'Set your profile picture to help artisans recognize you.';

    final bioLabel = widget.userType == UserType.artisan
        ? 'Bio or Summary'
        : 'About';

    final buttonLabel = _selectedImage != null || _bioController.text.isNotEmpty
        ? 'Complete Registration'
        : 'Continue';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back button and Progress
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 18.r,
                          color: const Color(0xFFE2725B),
                        ),
                        SizedBox(width: 4.w),
                        BodyText(
                          'Back',
                          size: BodySize.medium,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),

                  // Progress Indicator
                  const StepProgressIndicator(
                    totalSteps: 4,
                    currentStep: 3,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 20.h),

                    // Title
                    HeaderText(
                      'Upload a Profile Picture',
                      size: HeaderSize.h3,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    BodyText(
                      subtitle,
                      size: BodySize.medium,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    SizedBox(height: 32.h),

                    // Profile Picture Circle
                    Center(
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD9D9D9), // Light gray placeholder
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Action Buttons Row
                    Row(
                      children: [
                        // Take a picture button
                        Expanded(
                          child: GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 18.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BodyText(
                                    'Take a picture',
                                    size: BodySize.medium,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.primary,
                                    size: 24.r,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),

                        // Upload picture button
                        Expanded(
                          child: GestureDetector(
                            onTap: _uploadPicture,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 18.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BodyText(
                                    'Upload pciture',
                                    size: BodySize.medium,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    color: AppColors.primary,
                                    size: 24.r,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Bio/About Field
                    Container(
                      decoration: BoxDecoration(
                        color: _isBioFocused || _bioController.text.isNotEmpty
                            ? const Color(0xFFE0F2F1) // Light mint when focused/filled
                            : const Color(0xFFE8E8E8), // Light gray when empty
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                      child: TextField(
                        controller: _bioController,
                        focusNode: _bioFocusNode,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: bioLabel,
                          hintStyle: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.all(10.w),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Rebuild to update button label
                        },
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Continue/Complete Registration Button (Fixed at bottom)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: PrimaryButton(
                label: buttonLabel,
                onPressed: _handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
