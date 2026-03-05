import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/registration_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/models/user.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';

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
        await ref
            .read(authProvider.notifier)
            .login(_emailController.text.trim(), _passwordController.text);

        final authAsync = ref.read(authProvider);
        final user = authAsync.value;
        if (mounted && user != null) {
          final isClient = user.role == UserRole.client;
          final route = user.role == UserRole.artisan
              ? AppRoutes.artisanHome
              : AppRoutes.clientHome;
          context.go(
            AppRoutes.locationGate,
            extra: {
              'scope': isClient ? 'client' : 'artisan',
              'nextRoute': route,
            },
          );
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
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
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

  Future<String?> _selectGoogleUserType() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BodyText(
                'Choose account type',
                size: BodySize.medium,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 10.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const BodyText('Client', size: BodySize.small),
                onTap: () => Navigator.of(ctx).pop('client'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const BodyText('Artisan', size: BodySize.small),
                onTap: () => Navigator.of(ctx).pop('artisan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final firebaseCredential = await fb_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final firebaseIdToken = await firebaseCredential.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw ApiException('Unable to get Google token. Please try again.');
      }

      try {
        final isNewUser = await ref
            .read(authProvider.notifier)
            .loginWithGoogleToken(firebaseIdToken);
        if (isNewUser) {
          final authAsync = ref.read(authProvider);
          final user = authAsync.value;
          if (user == null) {
            throw ApiException('Unable to load account after Google sign-in');
          }
          await ref
              .read(registrationProvider.notifier)
              .seedFromGoogleUser(user);
          if (!mounted) return;
          context.push(
            AppRoutes.serviceSelection,
            extra: user.role == UserRole.artisan
                ? UserType.artisan
                : UserType.client,
          );
          return;
        }
      } catch (e) {
        final needsType =
            e is ApiException &&
            (e.message.toLowerCase().contains('user_type') ||
                e.message.toLowerCase().contains('first-time google'));
        if (!needsType) rethrow;

        final pickedType = await _selectGoogleUserType();
        if (pickedType == null) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        final isNewUser = await ref
            .read(authProvider.notifier)
            .loginWithGoogleToken(firebaseIdToken, userType: pickedType);
        if (isNewUser) {
          final authAsync = ref.read(authProvider);
          final user = authAsync.value;
          if (user == null) {
            throw ApiException('Unable to load account after Google sign-in');
          }
          await ref
              .read(registrationProvider.notifier)
              .seedFromGoogleUser(user);
          if (!mounted) return;
          context.push(
            AppRoutes.serviceSelection,
            extra: user.role == UserRole.artisan
                ? UserType.artisan
                : UserType.client,
          );
          return;
        }
      }

      final authAsync = ref.read(authProvider);
      final user = authAsync.value;
      if (mounted && user != null) {
        final isClient = user.role == UserRole.client;
        final route = user.role == UserRole.artisan
            ? AppRoutes.artisanHome
            : AppRoutes.clientHome;
        context.go(
          AppRoutes.locationGate,
          extra: {'scope': isClient ? 'client' : 'artisan', 'nextRoute': route},
        );
      }
    } catch (e) {
      if (mounted) {
        String message = 'Google sign-in failed. Please try again.';
        if (e is ApiException) {
          message = e.message;
        } else if (e is NetworkException) {
          message = e.message;
        } else if (e is UnauthorizedException) {
          message = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                        'Welcome back',
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
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
