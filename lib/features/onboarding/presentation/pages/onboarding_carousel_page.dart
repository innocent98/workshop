import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/routes/app_router.dart';
import '../../data/onboarding_data.dart';
import '../../domain/models/onboarding_content.dart';
import '../widgets/page_indicator.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';

class OnboardingCarouselPage extends StatefulWidget {
  final UserType userType;

  const OnboardingCarouselPage({
    super.key,
    required this.userType,
  });

  @override
  State<OnboardingCarouselPage> createState() => _OnboardingCarouselPageState();
}

class _OnboardingCarouselPageState extends State<OnboardingCarouselPage> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<OnboardingContent> _contents;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _contents = widget.userType == UserType.artisan
        ? OnboardingData.artisanOnboarding
        : OnboardingData.clientOnboarding;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToNextPage() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _navigateToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Navigate to Personal Information page with user type
    context.push(AppRoutes.personalInformation, extra: widget.userType);
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _contents.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 14.r,
                          color: AppColors.primary,
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

                  // Skip Button
                  GestureDetector(
                    onTap: _skipOnboarding,
                    child: Row(
                      children: [
                        BodyText(
                          'Skip',
                          size: BodySize.medium,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.r,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),

                        // Title
                        HeaderText(
                          _contents[index].title,
                          size: HeaderSize.h4,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 8.h),

                        // Description
                        BodyText(
                          _contents[index].description,
                          size: BodySize.medium,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        SizedBox(height: 20.h),

                        // Page Indicators
                        Center(
                          child: PageIndicator(
                            currentPage: _currentPage,
                            pageCount: _contents.length,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Image with Navigation Buttons
                        Expanded(
                          child: Stack(
                            children: [
                              // Image Container
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  image: DecorationImage(
                                    image: AssetImage(_contents[index].imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // Dark Gradient Overlay at bottom
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.black.withValues(alpha: 0.5),
                                      ],
                                      stops: const [0.0, 0.5, 0.8, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Navigation Buttons positioned at bottom of image
                              Positioned(
                                bottom: 20.h,
                                left: 20.w,
                                right: 20.w,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Previous Button
                                    if (_currentPage > 0)
                                      _NavigationButton(
                                        icon: Icons.arrow_back,
                                        onPressed: _navigateToPreviousPage,
                                      )
                                    else
                                      SizedBox(width: 56.r),

                                    // Next/Complete Button
                                    _NavigationButton(
                                      icon: isLastPage ? Icons.check : Icons.arrow_forward,
                                      onPressed: _navigateToNextPage,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24.r,
        ),
      ),
    );
  }
}
