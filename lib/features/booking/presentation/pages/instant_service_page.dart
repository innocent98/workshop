import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/common/verified_badge.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../widgets/service_checkbox.dart';
import '../../../artisan_profile/presentation/providers/artisan_public_profile_providers.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../../client_profile/presentation/providers/client_profile_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../data/booking_remote_datasource.dart';
import '../../../../core/network/dio_error_mapper.dart';

class InstantServicePage extends ConsumerStatefulWidget {
  final Artisan artisan;

  const InstantServicePage({super.key, required this.artisan});

  @override
  ConsumerState<InstantServicePage> createState() => _InstantServicePageState();
}

class _InstantServicePageState extends ConsumerState<InstantServicePage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final BookingRemoteDataSource _bookingRemoteDataSource =
      BookingRemoteDataSource();
  bool _isSubmitting = false;
  late final Set<int> _selectedServiceIndexes;

  @override
  void initState() {
    super.initState();
    _selectedServiceIndexes = <int>{
      widget.artisan.initialServiceIndex(_serviceOptions()),
    };
    // The API requires a budget range, so start from a visible default the
    // user can edit rather than an empty (invalid) form.
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

  double? _parseBudget(String value) {
    final normalized = value.replaceAll(',', '').trim();
    return double.tryParse(normalized);
  }

  List<ArtisanServiceOption> _serviceOptions() {
    if (widget.artisan.offeredServices.isNotEmpty) {
      return widget.artisan.offeredServices;
    }
    return [
      ArtisanServiceOption(
        id: widget.artisan.serviceId,
        name: widget.artisan.service,
      ),
    ];
  }

  Future<int?> _resolveServiceIdByName(String serviceName) async {
    final services = await ref.read(servicesProvider.future);
    for (final service in services) {
      if (service.name.trim().toLowerCase() ==
          serviceName.trim().toLowerCase()) {
        return int.tryParse(service.id);
      }
    }
    return null;
  }

  Future<void> _onBookArtisan() async {
    final minBudget = _parseBudget(_minBudgetController.text);
    final maxBudget = _parseBudget(_maxBudgetController.text);

    if (minBudget == null || maxBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget range')),
      );
      return;
    }
    if (maxBudget < minBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum budget must be >= minimum budget'),
        ),
      );
      return;
    }

    final options = _serviceOptions();
    if (options.isEmpty || _selectedServiceIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one service to continue'),
        ),
      );
      return;
    }
    final selectedIndexes = _selectedServiceIndexes.toList()..sort();
    final selectedServices = selectedIndexes
        .where((index) => index >= 0 && index < options.length)
        .map((index) => options[index])
        .toList();
    final selectedServiceIds = <int>[];
    for (final selectedService in selectedServices) {
      final serviceId =
          selectedService.id ??
          await _resolveServiceIdByName(selectedService.name);
      if (serviceId != null) {
        selectedServiceIds.add(serviceId);
      }
    }
    if (selectedServiceIds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to resolve selected services. Please retry.'),
        ),
      );
      return;
    }

    final locationData = ref.read(locationProvider).asData?.value;
    final clientProfile = ref.read(clientProfileProvider).asData?.value;
    final latitude =
        clientProfile?.locationLatitude ?? locationData?.latitude ?? 6.5244;
    final longitude =
        clientProfile?.locationLongitude ?? locationData?.longitude ?? 3.3792;
    final address = (clientProfile?.locationAddress?.trim().isNotEmpty ?? false)
        ? clientProfile!.locationAddress!.trim()
        : '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

    final notes = _notesController.text.trim();
    final selectedServiceNames = selectedServices.map((s) => s.name).toList();
    final description = notes.isNotEmpty
        ? notes
        : selectedServiceNames.join(', ');

    setState(() => _isSubmitting = true);
    try {
      await _bookingRemoteDataSource.createBooking(
        artisanId: widget.artisan.id,
        serviceIds: selectedServiceIds,
        jobDateUtc: DateTime.now().add(const Duration(minutes: 15)).toUtc(),
        jobAddress: address,
        jobLatitude: latitude,
        jobLongitude: longitude,
        budgetMin: minBudget,
        budgetMax: maxBudget,
        jobDescription: description,
      );

      if (!mounted) return;
      // Bookings tab must show the new request without a pull-to-refresh.
      ref.read(artisanBookingsProvider.notifier).refreshSilently();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artisanProfileAsync = ref.watch(
      artisanPublicProfileProvider(widget.artisan.id),
    );
    final artisanLocation = artisanProfileAsync.asData?.value.locationAddress;

    final serviceOptions = _serviceOptions();

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
        title: HeaderText('Instant Service', size: HeaderSize.h4),
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
                        ProfileAvatar(
                          imageUrl: widget.artisan.avatarUrl,
                          name: widget.artisan.name,
                          radius: 20,
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
                                    const VerifiedBadge(),
                                  BodyText(
                                    (widget.artisan.category != null &&
                                            widget.artisan.category!
                                                .trim()
                                                .isNotEmpty)
                                        ? widget.artisan.category!
                                        : widget.artisan.service,
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
                                      (artisanLocation != null &&
                                              artisanLocation.trim().isNotEmpty)
                                          ? artisanLocation.trim()
                                          : 'Location not specified',
                                      size: BodySize.small,
                                      color: AppColors.textSecondary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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

                    // Select service
                    const BodyText(
                      'Select service(s)',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: AppSizes.spacing),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing,
                        vertical: AppSizes.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Column(
                        children: List.generate(serviceOptions.length, (index) {
                          final option = serviceOptions[index];
                          final selected = _selectedServiceIndexes.contains(
                            index,
                          );
                          return InkWell(
                            borderRadius: BorderRadius.circular(8.r),
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedServiceIndexes.remove(index);
                                } else {
                                  _selectedServiceIndexes.add(index);
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  ServiceCheckbox(selected: selected),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: BodyText(
                                      option.name,
                                      size: BodySize.small,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

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
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
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
                    const BodyText(
                      'Budget range',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w600,
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
                    SizedBox(height: 6.h),
                    const BodyText(
                      'Default range, edit to match your budget',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
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
                onTap: _isSubmitting ? null : _onBookArtisan,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const BodyText(
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

// Custom Budget TextField Widget
class _BudgetTextField extends StatelessWidget {
  final TextEditingController controller;

  const _BudgetTextField({required this.controller});

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
          BodyText('₦', size: BodySize.small, color: AppColors.textPrimary),
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
