import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/models/user.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref.read(authProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text,
            );

        final user = ref.read(authProvider);
        if (mounted && user != null) {
          // Request location permission for clients (non-blocking)
          if (user.role == UserRole.client) {
            try {
              final hasRequested = await ref.read(locationProvider.notifier).hasRequestedPermissionBefore();
              if (!hasRequested) {
                await ref.read(locationProvider.notifier).requestPermission();
              }
            } catch (locationError) {
              // Log but don't block login - location is optional
              debugPrint('Location permission request failed: $locationError');
            }
          }

          if (user.role == UserRole.artisan) {
            context.go(AppRoutes.artisanHome);
          } else {
            context.go(AppRoutes.clientHome);
          }
        }
      } catch (e) {
        if (mounted) {
          String message = 'Login failed. Please try again.';
          if (e is ApiException) {
            message = e.message;
          } else if (e is NetworkException) {
            message = e.message;
          } else if (e is UnauthorizedException) {
            message = e.message;
          }

          debugPrint('Login error: $e');

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

  void _handleForgotPassword() {
    // Navigate to forgot password flow
    context.push(AppRoutes.forgotPasswordEmail);
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
            // Top Bar with Back button only
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.userTypeSelection);
                      }
                    },
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
                      // SizedBox(height: 20.h),

                      // Title - Personalized greeting
                      HeaderText(
                        'Welcome back Jeremiah',
                        size: HeaderSize.h3,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),

                      // Subtitle
                      BodyText(
                        'Welcome back! Enter your details to log in',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      SizedBox(height: 32.h),

                      // Email Field
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'jerryhook@woodwork.com',
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

                      // Password Field
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
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
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _handleForgotPassword,
                          child: BodyText(
                            'Forgot Password?',
                            size: BodySize.medium,
                            color: const Color(0xFFE2725B), // Coral color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                    label: _isLoading ? 'Logging in...' : 'Continue',
                    onPressed: _isLoading ? () {} : _handleLogin,
                  ),
                  SizedBox(height: 16.h),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyText(
                        'Don\'t have an account? ',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.userTypeSelection),
                        child: BodyText(
                          'Sign Up',
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
