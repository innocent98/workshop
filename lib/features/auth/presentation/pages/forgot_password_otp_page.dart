import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/password_reset_provider.dart';
import '../../../../core/network/api_exception.dart';

class ForgotPasswordOtpPage extends ConsumerStatefulWidget {
  final String email;

  const ForgotPasswordOtpPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends ConsumerState<ForgotPasswordOtpPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  int _countdown = 600; // 10 minutes as per API spec
  bool _canResend = false;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await ref.read(passwordResetProvider.notifier).sendResetCode(widget.email);

      if (mounted) {
        setState(() {
          _countdown = 600;
          _canResend = false;
        });
        _startCountdown();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset code resent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String message = 'Failed to resend code. Please try again.';
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
        setState(() => _isResending = false);
      }
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  bool _isOtpComplete() {
    return _getOtpCode().length == 6;
  }

  Future<void> _handleVerify() async {
    final code = _getOtpCode();
    if (code.length == 6) {
      setState(() => _isLoading = true);

      try {
        await ref.read(passwordResetProvider.notifier).verifyCode(code);

        if (mounted) {
          context.push(AppRoutes.forgotPasswordNewPassword, extra: widget.email);
        }
      } catch (e) {
        if (mounted) {
          String message = 'Invalid or expired code. Please try again.';
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
    final isOtpComplete = _isOtpComplete();

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    HeaderText(
                      'Enter the Code from your Email',
                      size: HeaderSize.h3,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    BodyText(
                      'We\'ve sent a code to your email — check your inbox!',
                      size: BodySize.medium,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    SizedBox(height: 40.h),

                    // OTP Input Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return _OTPBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) => _onDigitEntered(index, value),
                          onBackspace: () => _onBackspace(index),
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),

                    // Resend Code / Countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BodyText(
                          'Didn\'t receive code? ',
                          size: BodySize.medium,
                          color: AppColors.textSecondary,
                        ),
                        if (_canResend)
                          GestureDetector(
                            onTap: _isResending ? null : _resendCode,
                            child: BodyText(
                              _isResending ? 'Resending...' : 'Resend',
                              size: BodySize.medium,
                              color: const Color(0xFFE2725B),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          BodyText(
                            '0:${_countdown.toString().padLeft(2, '0')}',
                            size: BodySize.medium,
                            color: const Color(0xFFE2725B), // Coral
                          ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Continue Button (Fixed at bottom)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: PrimaryButton(
                label: _isLoading ? 'Verifying...' : 'Continue',
                onPressed: (_isLoading || !isOtpComplete) ? null : _handleVerify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OTPBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onBackspace;

  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<_OTPBox> createState() => _OTPBoxState();
}

class _OTPBoxState extends State<_OTPBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: _isFocused || widget.controller.text.isNotEmpty
            ? const Color(0xFFE0F2F1)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isFocused || widget.controller.text.isNotEmpty
              ? Colors.transparent
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        onTap: () {
          if (widget.controller.text.isNotEmpty) {
            widget.controller.clear();
            setState(() {});
          }
        },
        onEditingComplete: () {
          // Do nothing, let onChanged handle navigation
        },
      ),
    );
  }
}
