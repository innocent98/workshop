import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../artisan_profile/presentation/providers/artisan_public_profile_providers.dart';
import '../../../client_home/domain/models/artisan.dart';
import '../../../client_profile/presentation/providers/client_profile_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../data/booking_remote_datasource.dart';

class ScheduleServicePage extends ConsumerStatefulWidget {
  final Artisan artisan;

  const ScheduleServicePage({super.key, required this.artisan});

  @override
  ConsumerState<ScheduleServicePage> createState() =>
      _ScheduleServicePageState();
}

class _ScheduleServicePageState extends ConsumerState<ScheduleServicePage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final BookingRemoteDataSource _bookingRemoteDataSource =
      BookingRemoteDataSource();
  bool _isSubmitting = false;
  final Set<int> _selectedServiceIndexes = <int>{0};

  late DateTime _currentMonth;
  late int _selectedDay;
  String _selectedTimeSlot = '10:00 AM';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDay = now.day;
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

  Future<void> _onScheduleAppointment() async {
    final includeBudget = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radius),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _BudgetModal(
          minController: _minBudgetController,
          maxController: _maxBudgetController,
          onIncludeBudget: () => Navigator.pop(context, true),
          onIgnoreBudget: () => Navigator.pop(context, false),
        ),
      ),
    );

    if (includeBudget == null) return;
    await _submitBooking(ignoreBudget: !includeBudget);
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

  DateTime _selectedDateTime() {
    final parts = _selectedTimeSlot.split(' ');
    final hm = parts.first.split(':');
    var hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final period = parts.last.toUpperCase();

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(
      _currentMonth.year,
      _currentMonth.month,
      _selectedDay,
      hour,
      minute,
    );
  }

  Future<void> _submitBooking({required bool ignoreBudget}) async {
    final options = _serviceOptions();
    if (options.isEmpty || _selectedServiceIndexes.isEmpty) {
      if (!mounted) return;
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

    var minBudget = _parseBudget(_minBudgetController.text);
    var maxBudget = _parseBudget(_maxBudgetController.text);
    if (ignoreBudget) {
      minBudget = 0;
      maxBudget = 0;
    }

    if (minBudget == null || maxBudget == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget range')),
      );
      return;
    }
    if (maxBudget < minBudget) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum budget must be >= minimum budget'),
        ),
      );
      return;
    }

    final scheduled = _selectedDateTime();
    if (!scheduled.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a future date and time')),
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
        jobDateUtc: scheduled.toUtc(),
        jobAddress: address,
        jobLatitude: latitude,
        jobLongitude: longitude,
        budgetMin: minBudget,
        budgetMax: maxBudget,
        jobDescription: description,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      // Select first available day of the new month
      final lastDayOfMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        0,
      ).day;
      _selectedDay = _selectedDay <= lastDayOfMonth
          ? _selectedDay
          : lastDayOfMonth;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      // Select first available day of the new month
      final now = DateTime.now();
      final isCurrentMonth =
          _currentMonth.year == now.year && _currentMonth.month == now.month;
      _selectedDay = isCurrentMonth ? now.day : 1;
    });
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
        title: HeaderText('Schedule Service', size: HeaderSize.h4),
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
                          backgroundImage: _resolveImageProvider(
                            widget.artisan.avatarUrl,
                          ),
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

                    // Choose a date and time
                    const BodyText(
                      'Choose a date and time',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Calendar
                    _CalendarWidget(
                      currentMonth: _currentMonth,
                      selectedDay: _selectedDay,
                      onDaySelected: (day) {
                        setState(() {
                          _selectedDay = day;
                        });
                      },
                      onPreviousMonth: _previousMonth,
                      onNextMonth: _nextMonth,
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          label: 'Unavailable',
                        ),
                        SizedBox(width: AppSizes.spacing),
                        _LegendItem(
                          color: AppColors.textPrimary,
                          label: 'Available',
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacing),

                    // Time slots
                    _TimeSlotSelector(
                      selectedTimeSlot: _selectedTimeSlot,
                      onTimeSlotSelected: (timeSlot) {
                        setState(() {
                          _selectedTimeSlot = timeSlot;
                        });
                      },
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
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22.w,
                                    height: 22.h,
                                    child: Checkbox(
                                      value: selected,
                                      visualDensity: const VisualDensity(
                                        horizontal: -4,
                                        vertical: -4,
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (_) {
                                        setState(() {
                                          if (selected) {
                                            _selectedServiceIndexes.remove(
                                              index,
                                            );
                                          } else {
                                            _selectedServiceIndexes.add(index);
                                          }
                                        });
                                      },
                                    ),
                                  ),
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
                        maxLines: 3,
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
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.all(AppSizes.spacing),
              child: GestureDetector(
                onTap: _isSubmitting ? null : _onScheduleAppointment,
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
                            'Schedule Appointment',
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

  ImageProvider _resolveImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }
    return AssetImage(imageUrl);
  }
}

// Calendar Widget
class _CalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final int selectedDay;
  final Function(int) onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _CalendarWidget({
    required this.currentMonth,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  String _getMonthYear() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[currentMonth.month - 1]} ${currentMonth.year}';
  }

  List<int?> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    List<int?> days = [];

    // Add empty cells for days before the first day
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add the days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    return days;
  }

  bool _isPastDate(int day) {
    final today = DateTime.now();
    final date = DateTime(currentMonth.year, currentMonth.month, day);
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();

    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
              onPressed: onPreviousMonth,
            ),
            BodyText(
              _getMonthYear(),
              size: BodySize.medium,
              fontWeight: FontWeight.w600,
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
              onPressed: onNextMonth,
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingSmall),

        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
            return Expanded(
              child: Center(
                child: BodyText(
                  day,
                  size: BodySize.small,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: AppSizes.spacingSmall),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) return const SizedBox();

            final isPast = _isPastDate(day);
            final isSelected = day == selectedDay;

            return GestureDetector(
              onTap: isPast ? null : () => onDaySelected(day),
              child: Container(
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: BodyText(
                    day.toString(),
                    size: BodySize.small,
                    color: isSelected
                        ? Colors.white
                        : isPast
                        ? AppColors.textSecondary.withValues(alpha: 0.3)
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        BodyText(label, size: BodySize.small, color: AppColors.textSecondary),
      ],
    );
  }
}

// Time Slot Selector
class _TimeSlotSelector extends StatefulWidget {
  final String selectedTimeSlot;
  final Function(String) onTimeSlotSelected;

  const _TimeSlotSelector({
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  State<_TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<_TimeSlotSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to selected time after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTime();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTime() {
    final timeSlots = _generateTimeSlots();
    final selectedIndex = timeSlots.indexWhere(
      (slot) => '${slot['time']} ${slot['period']}' == widget.selectedTimeSlot,
    );

    if (selectedIndex != -1 && _scrollController.hasClients) {
      final itemHeight = 48.h; // Approximate height of each item
      final targetPosition = selectedIndex * itemHeight;
      final centerOffset = 75.h; // Half of container height to center the item

      _scrollController.animateTo(
        (targetPosition - centerOffset).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Map<String, String>> _generateTimeSlots() {
    final List<Map<String, String>> slots = [];

    // Generate AM times
    for (int hour = 8; hour <= 11; hour++) {
      slots.add({
        'time': '${hour.toString().padLeft(2, '0')}:00',
        'period': 'AM',
      });
      slots.add({
        'time': '${hour.toString().padLeft(2, '0')}:30',
        'period': 'AM',
      });
    }

    // Add 12:00 PM and 12:30 PM
    slots.add({'time': '12:00', 'period': 'PM'});
    slots.add({'time': '12:30', 'period': 'PM'});

    // Generate PM times
    for (int hour = 1; hour <= 8; hour++) {
      slots.add({
        'time': '${hour.toString().padLeft(2, '0')}:00',
        'period': 'PM',
      });
      slots.add({
        'time': '${hour.toString().padLeft(2, '0')}:30',
        'period': 'PM',
      });
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();

    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: timeSlots.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final slot = timeSlots[index];
          final timeSlot = '${slot['time']} ${slot['period']}';
          final isSelected = timeSlot == widget.selectedTimeSlot;

          return GestureDetector(
            onTap: () => widget.onTimeSlotSelected(timeSlot),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacing,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cardBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyText(
                    slot['time']!,
                    size: BodySize.small,
                    color: AppColors.textPrimary,
                  ),
                  BodyText(
                    slot['period']!,
                    size: BodySize.small,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Budget Modal
class _BudgetModal extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final VoidCallback onIncludeBudget;
  final VoidCallback onIgnoreBudget;

  const _BudgetModal({
    required this.minController,
    required this.maxController,
    required this.onIncludeBudget,
    required this.onIgnoreBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              IconButton(
                icon: Icon(Icons.close, size: 24.r),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const BodyText(
            'Helps the artisan provide a relevant quote',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSizes.spacing),

          // Budget Range Inputs
          Row(
            children: [
              Expanded(child: _BudgetTextField(controller: minController)),
              SizedBox(width: AppSizes.spacing),
              BodyText(
                'TO',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSizes.spacing),
              Expanded(child: _BudgetTextField(controller: maxController)),
            ],
          ),
          SizedBox(height: AppSizes.spacing),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onIncludeBudget,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: const Center(
                      child: BodyText(
                        'Include Budget',
                        size: BodySize.small,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spacing),
              Expanded(
                child: GestureDetector(
                  onTap: onIgnoreBudget,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: const Center(
                      child: BodyText(
                        'Ignore Budget',
                        size: BodySize.small,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Budget TextField Widget
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
          BodyText('NGN', size: BodySize.small, color: AppColors.textPrimary),
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
