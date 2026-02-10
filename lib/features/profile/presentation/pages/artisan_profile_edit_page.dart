import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../artisan_profile/domain/models/artisan_profile.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
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
      if (!mounted) return;
      setState(() {
        _selectedServiceIds = services.map((service) => service.id).toSet();
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

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Artisan Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
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
                'Services you provide',
                size: BodySize.medium,
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
              servicesAsync.when(
                data: (services) {
                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: services.map((service) {
                      final selected = _selectedServiceIds.contains(service.id);
                      return FilterChip(
                        selected: selected,
                        label: Text(service.name),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedServiceIds.add(service.id);
                            } else {
                              _selectedServiceIds.remove(service.id);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  );
                },
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (error, _) => BodyText(
                  'Failed to load services',
                  size: BodySize.small,
                  color: AppColors.error,
                ),
              ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAFA),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const BodyText(
                'This updates profile details in the backend. Portfolio is managed separately.',
                size: BodySize.small,
                color: AppColors.textSecondary,
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
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
