import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/indicators/step_progress_indicator.dart';
import '../../../../core/widgets/cards/service_card.dart';
import '../../../../core/routes/app_router.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';

class ServiceSelectionPage extends StatefulWidget {
  final UserType userType;

  const ServiceSelectionPage({
    super.key,
    required this.userType,
  });

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  final Set<String> _selectedServices = {};

  // Client services
  final List<Map<String, String>> _clientServices = [
    {
      'title': 'Construction',
      'image': 'assets/images/services/construction.jpg',
    },
    {
      'title': 'Car repairs/parts',
      'image': 'assets/images/services/car_repairs.jpg',
    },
    {
      'title': 'Electronics/repairs',
      'image': 'assets/images/services/electronics.jpg',
    },
    {
      'title': 'Dry Cleaning',
      'image': 'assets/images/services/dry_cleaning.jpg',
    },
    {
      'title': 'Electrical',
      'image': 'assets/images/services/electrical.jpg',
    },
    {
      'title': 'Fashion Design',
      'image': 'assets/images/services/fashion_design.jpg',
    },
  ];

  // Artisan services
  final List<Map<String, String>> _artisanServices = [
    {
      'title': 'Electrician',
      'image': 'assets/images/services/electrician.jpg',
    },
    {
      'title': 'Plumber',
      'image': 'assets/images/services/plumber.jpg',
    },
    {
      'title': 'Carpenter',
      'image': 'assets/images/services/carpenter.jpg',
    },
    {
      'title': 'Cleaner',
      'image': 'assets/images/services/cleaner.jpg',
    },
    {
      'title': 'Painter',
      'image': 'assets/images/services/painter.jpg',
    },
    {
      'title': 'Make up artist',
      'image': 'assets/images/services/makeup_artist.jpg',
    },
  ];

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _handleSave() {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: Save selected services
    print('Selected services: $_selectedServices');
    // Navigate to profile picture page
    context.push(AppRoutes.profilePicture, extra: widget.userType);
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.userType == UserType.client
        ? _clientServices
        : _artisanServices;

    final title = widget.userType == UserType.client
        ? 'Select your Services of Interest'
        : 'Select the Service You Offer';

    final subtitle = widget.userType == UserType.client
        ? 'Select not less than one service, we\'ll match you with trusted artisans'
        : 'Choose the type of work you\'re skilled in so we can connect you to the right clients.';

    final buttonLabel = widget.userType == UserType.client
        ? 'Save Interest'
        : 'Save';

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
                    currentStep: 2,
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
                      title,
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

                    // Service Cards Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.85, // Adjust card height
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final title = service['title']!;
                        final image = service['image']!;

                        return ServiceCard(
                          imagePath: image,
                          title: title,
                          isSelected: _selectedServices.contains(title),
                          onTap: () => _toggleService(title),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Save Button (Fixed at bottom)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: PrimaryButton(
                label: buttonLabel,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
