import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/indicators/step_progress_indicator.dart';
import '../../../../core/widgets/cards/service_card.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/registration_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';
import '../../../services/presentation/providers/services_provider.dart';

class ServiceSelectionPage extends ConsumerStatefulWidget {
  final UserType userType;

  const ServiceSelectionPage({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends ConsumerState<ServiceSelectionPage> {
  final Set<String> _selectedServices = {};
  bool _isLoading = false;

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  Future<void> _handleSave() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(registrationProvider.notifier).registerServices(
            _selectedServices.toList(),
          );

      if (mounted) {
        context.push(AppRoutes.profilePicture, extra: widget.userType);
      }
    } catch (e) {
      if (mounted) {
        String message = 'Something went wrong. Please try again.';
        if (e is ApiException) {
          message = e.message;
        } else if (e is NetworkException) {
          message = e.message;
        } else if (e is UnauthorizedException) {
          message = e.message;
        }

        debugPrint('Save services error: $e');

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

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

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
              child: servicesAsync.when(
                data: (services) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          childAspectRatio: 0.85,
                        ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final serviceName = service.name;
                          final imageUrl = service.imageUrl;

                          return ServiceCard(
                            imagePath: imageUrl ?? '',
                            title: serviceName,
                            isSelected: _selectedServices.contains(serviceName),
                            onTap: () => _toggleService(serviceName),
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      SizedBox(height: 16.h),
                      BodyText(
                        'Failed to load services',
                        size: BodySize.large,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => ref.refresh(servicesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Save Button (Fixed at bottom)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: PrimaryButton(
                label: _isLoading ? 'Saving...' : buttonLabel,
                onPressed: _isLoading ? () {} : _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
