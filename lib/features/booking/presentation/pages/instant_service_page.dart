import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../client_home/domain/models/artisan.dart';

class InstantServicePage extends StatefulWidget {
  final Artisan artisan;

  const InstantServicePage({
    super.key,
    required this.artisan,
  });

  @override
  State<InstantServicePage> createState() => _InstantServicePageState();
}

class _InstantServicePageState extends State<InstantServicePage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();

  // Service selection state
  final Map<String, bool> _selectedServices = {
    'Miter and Cope Joint Fabrication': false,
    'Door and Window Casing Installation': true,
    'Hardware Installation (Hinges, Drawer Slides, Locks)': true,
    'Advanced Wood Joinery': true,
  };

  @override
  void initState() {
    super.initState();
    _minBudgetController.text = '25,000';
    _maxBudgetController.text = '35,000';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  void _onBookArtisan() {
    // TODO: Implement booking functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24.r,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: HeaderText(
          'Instant Service',
          size: HeaderSize.h4,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
              size: 24.r,
            ),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artisan Profile Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: AssetImage(widget.artisan.avatarUrl),
                        ),
                        SizedBox(width: AppSizes.spacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name with verified badge and service
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 2.w,
                                children: [
                                  BodyText(
                                    widget.artisan.name,
                                    size: BodySize.small,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  if (widget.artisan.isVerified)
                                    Icon(
                                      Icons.verified,
                                      size: 14.r,
                                      color: Colors.red,
                                    ),
                                  BodyText(
                                    widget.artisan.service,
                                    size: BodySize.small,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.r,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: BodyText(
                                      '20, Cresent Ekeng Street, Uyo',
                                      size: BodySize.small,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // What service do you need?
                    const BodyText(
                      'What service do you need?',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Service Checkboxes
                    ..._selectedServices.keys.map((service) {
                      return _ServiceCheckbox(
                        label: service,
                        value: _selectedServices[service]!,
                        onChanged: (value) {
                          setState(() {
                            _selectedServices[service] = value!;
                          });
                        },
                      );
                    }),

                    SizedBox(height: AppSizes.spacing),

                    // Additional Note Section
                    RichText(
                      text: TextSpan(
                        text: 'Additional Note ',
                        style: TextStyle(
                          fontSize: AppSizes.body,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: '(optional)',
                            style: TextStyle(
                              fontSize: AppSizes.body,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Notes TextField
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing,
                        vertical: AppSizes.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: AppSizes.caption,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe the nature of the work',
                          hintStyle: TextStyle(
                            fontSize: AppSizes.caption,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge),

                    // Budget Range Section
                    RichText(
                      text: TextSpan(
                        text: 'Budget range ',
                        style: TextStyle(
                          fontSize: AppSizes.body,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: '(optional)',
                            style: TextStyle(
                              fontSize: AppSizes.body,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const BodyText(
                      'Helps the artisan provide a relevant quote',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Budget Range Inputs
                    Row(
                      children: [
                        Expanded(
                          child: _BudgetTextField(
                            controller: _minBudgetController,
                          ),
                        ),
                        SizedBox(width: AppSizes.spacing),
                        BodyText(
                          'TO',
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _BudgetTextField(
                            controller: _maxBudgetController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Rate Info Box
                    Container(
                      padding: EdgeInsets.all(AppSizes.spacing),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'The standard rate for a basic carpentry service is generally between ',
                          style: TextStyle(
                            fontSize: AppSizes.caption,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'NGN 20,000',
                              style: TextStyle(
                                fontSize: AppSizes.caption,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(
                                fontSize: AppSizes.caption,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: 'NGN 200,000',
                              style: TextStyle(
                                fontSize: AppSizes.caption,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '. This range is considered fair and acceptable by most artisans.',
                              style: TextStyle(
                                fontSize: AppSizes.caption,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.all(AppSizes.spacing),
              child: GestureDetector(
                onTap: _onBookArtisan,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Center(
                    child: BodyText(
                      'Book Artisan',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Checkbox Widget
class _ServiceCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _ServiceCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacing),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: 16.r,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: BodyText(
              label,
              size: BodySize.small,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Budget TextField Widget
class _BudgetTextField extends StatelessWidget {
  final TextEditingController controller;

  const _BudgetTextField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.spacing,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: [
          BodyText(
            'NGN',
            size: BodySize.small,
            color: AppColors.textPrimary,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: AppSizes.bodySmall,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
