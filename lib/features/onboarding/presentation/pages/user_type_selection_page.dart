import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/routes/app_router.dart';

enum UserType { artisan, client }

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage>
    with SingleTickerProviderStateMixin {
  UserType? _selectedUserType;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_selectedUserType == null) return;
    context.push(AppRoutes.onboarding, extra: _selectedUserType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Hero Image
                  Container(
                    height: 280.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/welcome.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Title
                  HeaderText(
                    'Welcome to Workshop',
                    size: HeaderSize.h4,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  BodyText(
                    'We are connecting skilled artisans with clients who value quality craftsmanship.',
                    size: BodySize.medium,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  SizedBox(height: 28.h),

                  // Selection Label
                  BodyText(
                    'Tell us who you are:',
                    size: BodySize.medium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 12.h),

                  // User Type Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _UserTypeCard(
                          title: "I'm an Artisan",
                          description: 'A skilled professional\nlooking for work.',
                          iconPath: 'assets/images/artisan_icon.png',
                          isSelected: _selectedUserType == UserType.artisan,
                          onTap: () {
                            setState(() {
                              _selectedUserType = UserType.artisan;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _UserTypeCard(
                          title: "I'm a Client",
                          description: 'An individual or business\nseeking to hire artisans.',
                          iconPath: 'assets/images/client_icon.png',
                          isSelected: _selectedUserType == UserType.client,
                          onTap: () {
                            setState(() {
                              _selectedUserType = UserType.client;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Continue Button
                  PrimaryButton(
                    label: 'Continue',
                    onPressed: _selectedUserType != null ? _handleContinue : null,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 160.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE0F2F1)  // Light mint green
              : const Color(0xFFF5F5F5),  // Light gray
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 0,
          ),
        ),
        child: Stack(
          children: [
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Image.asset(
                  iconPath,
                  width: 36.r,
                  height: 36.r,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 12.h),

                // Title
                BodyText(
                  title,
                  size: BodySize.medium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                // Description
                BodyText(
                  description,
                  size: BodySize.small,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                  height: 1.3,
                  maxLines: 2,
                ),
              ],
            ),

            // Checkmark indicator (top-right)
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16.r,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
