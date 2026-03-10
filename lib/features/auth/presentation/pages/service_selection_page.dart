import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/service_guard_provider.dart';
import '../../../../core/providers/registration_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/cards/service_card.dart';
import '../../../../core/widgets/indicators/step_progress_indicator.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../onboarding/presentation/pages/user_type_selection_page.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class ServiceSelectionPage extends ConsumerStatefulWidget {
  final UserType userType;

  const ServiceSelectionPage({super.key, required this.userType});

  @override
  ConsumerState<ServiceSelectionPage> createState() =>
      _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends ConsumerState<ServiceSelectionPage> {
  final Set<String> _selectedServices = <String>{};
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource();
  bool _isLoading = false;
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  String _categoryImage(String categoryName) {
    switch (categoryName) {
      case 'Construction & Building Trades':
        return 'https://res.cloudinary.com/dlw4um9gc/image/upload/v1769783411/construction_mt2zp8.png';
      case 'Mechanical & Automotive Trades':
        return 'https://res.cloudinary.com/dlw4um9gc/image/upload/v1769783410/car_repairs_mjsx70.png';
      case 'Electrical & Electronics Trades':
        return 'https://res.cloudinary.com/dlw4um9gc/image/upload/v1769783640/electronics_kqfajq.png';
      case 'Fashion & Personal Care Trades':
        return 'https://res.cloudinary.com/dlw4um9gc/image/upload/v1769783641/fashion_design_mupfnt.png';
      case 'Food Production & Catering Trades':
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80';
      case 'Wood & Craft Production':
        return 'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?auto=format&fit=crop&w=1200&q=80';
      case 'Printing & Creative Production':
        return 'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=1200&q=80';
      case 'Cleaning Services':
        return 'https://res.cloudinary.com/dlw4um9gc/image/upload/v1769783410/cleaner_wizbgr.png';
      default:
        return '';
    }
  }

  Future<void> _openCategoryServicesSheet({
    required String categoryId,
    required String categoryName,
  }) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final initial = (_selectedCategoryId == categoryId)
            ? _selectedServices
            : <String>{};
        return _CategoryServicesSheet(
          categoryId: categoryId,
          categoryName: categoryName,
          initialSelected: initial,
        );
      },
    );

    if (result == null || !mounted) return;
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _selectedServices
        ..clear()
        ..addAll(result);
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
      final registrationData = ref.read(registrationProvider).value;
      final isRegistrationFlow = registrationData?.userId != null;

      if (isRegistrationFlow) {
        await ref
            .read(registrationProvider.notifier)
            .registerServices(_selectedServices.toList());
      } else {
        await _authRemoteDataSource.updateMyServices(
          _selectedServices.toList(),
        );
      }

      final user = ref.read(authProvider).value;
      if (user != null) {
        ref
            .read(serviceGuardProvider.notifier)
            .setForUser(userId: user.id, hasServices: true);
      }

      if (!mounted) return;
      if (isRegistrationFlow) {
        context.push(AppRoutes.profilePicture, extra: widget.userType);
      } else {
        final route = user?.role == UserRole.artisan
            ? AppRoutes.artisanHome
            : AppRoutes.clientHome;
        context.go(route);
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
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    final title = widget.userType == UserType.client
        ? 'Select your Services of Interest'
        : 'Select the Service You Offer';

    final subtitle = widget.userType == UserType.client
        ? 'Choose one category, then select one or more services from the bottom sheet.'
        : 'Choose one category, then select one or more services you offer from the bottom sheet.';

    final buttonLabel = widget.userType == UserType.client
        ? 'Save Interest'
        : 'Save';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          size: BodySize.small,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const StepProgressIndicator(totalSteps: 4, currentStep: 2),
                ],
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderText(
                          title,
                          size: HeaderSize.h3,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 8.h),
                        BodyText(
                          subtitle,
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Select category',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 0.84,
                              ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return ServiceCard(
                              imagePath: _categoryImage(category.name),
                              title: category.name,
                              isSelected: _selectedCategoryId == category.id,
                              onTap: () => _openCategoryServicesSheet(
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                        if (_selectedCategoryId != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F4F2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedCategoryName ??
                                            'Selected category',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${_selectedServices.length} service(s) selected',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _openCategoryServicesSheet(
                                    categoryId: _selectedCategoryId!,
                                    categoryName:
                                        _selectedCategoryName ??
                                        'Selected category',
                                  ),
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      BodyText(
                        'Failed to load categories',
                        size: BodySize.medium,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => ref.refresh(serviceCategoriesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

class _CategoryServicesSheet extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  final Set<String> initialSelected;

  const _CategoryServicesSheet({
    required this.categoryId,
    required this.categoryName,
    required this.initialSelected,
  });

  @override
  ConsumerState<_CategoryServicesSheet> createState() =>
      _CategoryServicesSheetState();
}

class _CategoryServicesSheetState
    extends ConsumerState<_CategoryServicesSheet> {
  late final TextEditingController _searchController;
  late Set<String> _localSelected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _localSelected = <String>{...widget.initialSelected};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(
      servicesByCategoryProvider(widget.categoryId),
    );
    final maxHeight = math.min(MediaQuery.of(context).size.height * 0.9, 720.h);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 12.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
        ),
        child: SizedBox(
          height: maxHeight,
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.categoryName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 18.r,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select one or more services',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 10.sp),
                  onChanged: (value) {
                    setState(() => _query = value.trim().toLowerCase());
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 18.r,
                    ),
                    hintText: 'Search services',
                    hintStyle: TextStyle(fontSize: 10.sp),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_localSelected.length} selected',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Expanded(
                child: servicesAsync.when(
                  data: (services) {
                    final filtered = _query.isEmpty
                        ? services
                        : services
                              .where(
                                (s) => s.name.toLowerCase().contains(_query),
                              )
                              .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No services match your search',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 6.h),
                      itemBuilder: (context, index) {
                        final service = filtered[index];
                        final selected = _localSelected.contains(service.name);
                        return InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _localSelected.remove(service.name);
                              } else {
                                _localSelected.add(service.name);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFBEDE8)
                                  : const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFEAEAEA),
                                width: selected ? 1.2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : const Color(0xFFCFCFCF),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: selected
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 11.r,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.textPrimary,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Failed to load services',
                      style: TextStyle(fontSize: 10.sp, color: AppColors.error),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              PrimaryButton(
                label: 'Apply Selection',
                onPressed: () => Navigator.of(context).pop(_localSelected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
