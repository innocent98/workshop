import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../artisan_profile/domain/models/artisan_profile.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/widgets/cards/service_card.dart';
import '../providers/profile_actions_provider.dart';

class ArtisanProfileEditPage extends ConsumerStatefulWidget {
  final ArtisanProfile profile;
  final String? phoneNumber;

  const ArtisanProfileEditPage({
    super.key,
    required this.profile,
    this.phoneNumber,
  });

  @override
  ConsumerState<ArtisanProfileEditPage> createState() =>
      _ArtisanProfileEditPageState();
}

class _ArtisanProfileEditPageState
    extends ConsumerState<ArtisanProfileEditPage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _specializationController;
  late final TextEditingController _yearsController;
  late final TextEditingController _rateMinController;
  late final TextEditingController _rateMaxController;
  late final TextEditingController _radiusController;

  bool _isSaving = false;
  bool _isLoadingSelectedServices = true;
  Set<String> _selectedServiceIds = <String>{};
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _specializationController = TextEditingController(
      text: widget.profile.specialization ?? '',
    );
    _yearsController = TextEditingController(
      text: widget.profile.yearsOfExperience?.toString() ?? '',
    );
    _rateMinController = TextEditingController(
      text: widget.profile.hourlyRateMin?.toStringAsFixed(0) ?? '',
    );
    _rateMaxController = TextEditingController(
      text: widget.profile.hourlyRateMax?.toStringAsFixed(0) ?? '',
    );
    _radiusController = TextEditingController(
      text: widget.profile.serviceRadiusKm?.toStringAsFixed(0) ?? '10',
    );
    _loadSelectedServices();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _specializationController.dispose();
    _yearsController.dispose();
    _rateMinController.dispose();
    _rateMaxController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedServices() async {
    try {
      final services = await ref
          .read(profileRemoteDataSourceProvider)
          .fetchMyArtisanServices();
      final allServices = await ref.read(servicesProvider.future);
      if (!mounted) return;

      String? resolvedCategoryId;
      for (final selectedService in services) {
        final match = allServices.where((s) => s.id == selectedService.id);
        if (match.isNotEmpty) {
          resolvedCategoryId = match.first.categoryId;
          if (resolvedCategoryId != null && resolvedCategoryId.isNotEmpty) {
            break;
          }
        }
      }

      setState(() {
        _selectedServiceIds = services.map((service) => service.id).toSet();
        _selectedCategoryId = resolvedCategoryId;
        if (resolvedCategoryId != null) {
          final categoryMatch = allServices.firstWhere(
            (s) => s.categoryId == resolvedCategoryId,
            orElse: () => allServices.first,
          );
          _selectedCategoryName = categoryMatch.categoryName;
        }
      });
    } catch (_) {
      // Best-effort prefill; selection can still be updated manually.
    } finally {
      if (mounted) {
        setState(() => _isLoadingSelectedServices = false);
      }
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final minRate = double.tryParse(_rateMinController.text.trim());
    final maxRate = double.tryParse(_rateMaxController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    final radius = double.tryParse(_radiusController.text.trim());
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty) {
      _showMessage('Full name is required');
      return;
    }

    if (minRate != null && maxRate != null && maxRate < minRate) {
      _showMessage('Maximum rate must be greater than minimum rate');
      return;
    }

    if (radius != null && (radius < 1 || radius > 100)) {
      _showMessage('Service radius must be between 1 and 100 km');
      return;
    }
    if (_selectedServiceIds.isEmpty) {
      _showMessage('Select at least one service');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileRemoteDataSourceProvider)
          .updateArtisanProfile(
            fullName: fullName,
            phoneNumber: phone.isEmpty ? null : phone,
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            locationAddress: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            specialization: _specializationController.text.trim().isEmpty
                ? null
                : _specializationController.text.trim(),
            yearsOfExperience: years,
            hourlyRateMin: minRate,
            hourlyRateMax: maxRate,
            serviceRadiusKm: radius,
          );
      await ref
          .read(profileRemoteDataSourceProvider)
          .updateMyArtisanServices(_selectedServiceIds.toList());

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
    final initial = (_selectedCategoryId == categoryId)
        ? _selectedServiceIds
        : <String>{};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _EditProfileServicesSheet(
        categoryId: categoryId,
        categoryName: categoryName,
        initialSelected: initial,
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _selectedServiceIds
        ..clear()
        ..addAll(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Artisan Profile',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Save', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _field('Full name', _fullNameController),
            _field(
              'Phone number',
              _phoneController,
              keyboard: TextInputType.phone,
            ),
            _field('Bio', _bioController, maxLines: 4),
            _field('Location', _locationController),
            _field('Specialization', _specializationController),
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Years experience',
                    _yearsController,
                    keyboard: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _field(
                    'Radius (km)',
                    _radiusController,
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Min hourly rate',
                    _rateMinController,
                    keyboard: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _field(
                    'Max hourly rate',
                    _rateMaxController,
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerLeft,
              child: BodyText(
                'Category',
                size: BodySize.small,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            if (_isLoadingSelectedServices)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: const LinearProgressIndicator(minHeight: 2),
              )
            else
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isNotEmpty && _selectedCategoryId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _selectedCategoryId = categories.first.id;
                        _selectedCategoryName = categories.first.name;
                      });
                    });
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 0.85,
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
                      SizedBox(height: 10.h),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '${_selectedServiceIds.length} service(s) selected',
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
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (error, _) => BodyText(
                  'Failed to load categories',
                  size: BodySize.small,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 10.sp),
          floatingLabelStyle: TextStyle(fontSize: 10.sp),
          hintStyle: TextStyle(fontSize: 10.sp),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _EditProfileServicesSheet extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  final Set<String> initialSelected;

  const _EditProfileServicesSheet({
    required this.categoryId,
    required this.categoryName,
    required this.initialSelected,
  });

  @override
  ConsumerState<_EditProfileServicesSheet> createState() =>
      _EditProfileServicesSheetState();
}

class _EditProfileServicesSheetState
    extends ConsumerState<_EditProfileServicesSheet> {
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 12.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
        ),
        child: SizedBox(
          height: 620.h,
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
                        final selected = _localSelected.contains(service.id);
                        return InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _localSelected.remove(service.id);
                              } else {
                                _localSelected.add(service.id);
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 44.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(_localSelected),
                  child: Text(
                    'Apply Selection',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
