import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/password_reset_provider.dart';
import '../../../../core/network/api_exception.dart';

class ForgotPasswordNewPasswordPage extends ConsumerStatefulWidget {
  final String email;

  const ForgotPasswordNewPasswordPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ForgotPasswordNewPasswordPage> createState() => _ForgotPasswordNewPasswordPageState();
}

class _ForgotPasswordNewPasswordPageState extends ConsumerState<ForgotPasswordNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid() {
    return _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.length >= 8;
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref.read(passwordResetProvider.notifier).resetPassword(
              _passwordController.text,
            );

        ref.read(passwordResetProvider.notifier).clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully'),
              backgroundColor: AppColors.success,
            ),
          );

          context.go(AppRoutes.login);
        }
      } catch (e) {
        if (mounted) {
          String message = 'Failed to reset password. Please try again.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back button only
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
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
                      // Title
                      HeaderText(
                        'Create a New Password',
                        size: HeaderSize.h3,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),

                      // Subtitle
                      BodyText(
                        'Set a new password to secure your account.',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      SizedBox(height: 32.h),

                      // Password Field
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: '98^^98d@J7y',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                            size: 20.r,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Confirm Password Field
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                            size: 20.r,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
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
              child: PrimaryButton(
                label: _isLoading ? 'Resetting Password...' : 'Continue',
                onPressed: (_isLoading || !_isPasswordValid()) ? null : _handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
