import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/indicators/step_progress_indicator.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/registration_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';

class PersonalInformationPage extends ConsumerStatefulWidget {
  final UserType userType;

  const PersonalInformationPage({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends ConsumerState<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userType = widget.userType == UserType.artisan ? 'artisan' : 'client';
        await ref.read(registrationProvider.notifier).registerPersonalInfo(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              userType: userType,
            );

        if (mounted) {
          context.push(AppRoutes.password, extra: widget.userType);
        }
      } catch (e) {
        if (mounted) {
          String message = 'An error occurred. Please try again.';
          if (e is ApiException) {
            message = e.message;
          } else if (e is NetworkException) {
            message = e.message;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign-In
    print('Google Sign-In clicked');
  }

  @override
  Widget build(BuildContext context) {
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
                          color: const Color(0xFFFF6B6B),
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
                    currentStep: 1,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 20.h),

                      // Title
                      HeaderText(
                        'Personal Information',
                        size: HeaderSize.h3,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),

                      // Subtitle
                      BodyText(
                        'Fill in your details to complete your profile.',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 32.h),

                      // Full Name Field
                      AppTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hintText: 'Jason Ndak',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Email Field
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'jason.woodwork@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Phone Number Field
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: '0708 738 9271',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32.h),

                      // Divider with "or"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.border,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: BodyText(
                              'or',
                              size: BodySize.medium,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.border,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Google Sign-In Button
                      GestureDetector(
                        onTap: _handleGoogleSignIn,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3D3D3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google Logo
                              Image.asset(
                                'assets/images/google.png',
                                width: 24.r,
                                height: 24.r,
                              ),
                              SizedBox(width: 12.w),
                              BodyText(
                                'Continue with Google',
                                size: BodySize.large,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),

            // Continue Button (Fixed at bottom)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _isLoading ? 'Loading...' : 'Continue',
                    onPressed: _isLoading ? () {} : _handleContinue,
                  ),
                  SizedBox(height: 16.h),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyText(
                        'Already have an account? ',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.login),
                        child: BodyText(
                          'Login',
                          size: BodySize.medium,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
