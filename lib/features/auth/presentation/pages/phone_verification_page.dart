import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/routes/app_router.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';

class PhoneVerificationPage extends StatefulWidget {
  final UserType userType;

  const PhoneVerificationPage({
    super.key,
    required this.userType,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  void _handleVerify() {
    final code = _getOtpCode();
    if (code.length == 6) {
      // Navigate to service selection based on user type
      context.push(AppRoutes.serviceSelection, extra: widget.userType);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 20.h),

                    // Title
                    HeaderText(
                      'Verify your account',
                      size: HeaderSize.h3,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    BodyText(
                      'Enter the code we sent your number to verify it\'s yours.',
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
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Verify Button (Fixed at bottom)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: PrimaryButton(
                label: 'Verify',
                onPressed: _handleVerify,
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
        },
        onTap: () {
          if (widget.controller.text.isNotEmpty) {
            widget.controller.clear();
          }
        },
        onEditingComplete: () {
          // Do nothing, let onChanged handle navigation
        },
      ),
    );
  }
}
