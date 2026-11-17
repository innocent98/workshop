import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../domain/models/artisan_booking.dart';
import '../providers/artisan_bookings_provider.dart';
import '../widgets/artisan_job_card.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/widgets/common/error_state.dart';
import '../../../../core/utils/money_format.dart';

class ArtisanJobsPage extends ConsumerStatefulWidget {
  const ArtisanJobsPage({super.key});

  @override
  ConsumerState<ArtisanJobsPage> createState() => _ArtisanJobsPageState();
}

class _ArtisanJobsPageState extends ConsumerState<ArtisanJobsPage> {
  int _mainTabIndex = 0; // 0: Upcoming, 1: History
  int _filterIndex = 0;

  final List<String> _upcomingFilters = ['All', 'Pending', 'Accepted', 'Today'];
  final List<String> _historyFilters = [
    'All',
    'Completed',
    'Cancelled',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(artisanBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    _buildMainTab('Upcoming', 0),
                    _buildMainTab('History', 1),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 32.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _mainTabIndex == 0
                    ? _upcomingFilters.length
                    : _historyFilters.length,
                itemBuilder: (context, index) {
                  final filters = _mainTabIndex == 0
                      ? _upcomingFilters
                      : _historyFilters;
                  return _buildFilterChip(filters[index], index);
                },
              ),
            ),
            SizedBox(height: 16.h),
            bookingsState.when(
              data: (bookings) {
                final filtered = _getFilteredBookings(bookings);
                return Expanded(
                  child: Column(
                    children: [
                      if (_mainTabIndex == 1) _buildHistorySummary(bookings),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => ref
                              .read(artisanBookingsProvider.notifier)
                              .refresh(),
                          child: filtered.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: 96.h),
                                    Center(
                                      child: BodyText(
                                        'No jobs found',
                                        size: BodySize.medium,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : ListView(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  children: filtered
                                      .map(
                                        (booking) =>
                                            _buildBookingCard(context, booking),
                                      )
                                      .toList(),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () =>
                  const Expanded(child: Center(child: LoadingIndicator())),
              error: (error, _) => Expanded(
                child: ErrorState(
                  error: error,
                  title: 'Could not load your jobs',
                  onRetry: () =>
                      ref.read(artisanBookingsProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTab(String label, int index) {
    final isActive = _mainTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _mainTabIndex = index;
          _filterIndex = 0;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: BodyText(
            label,
            size: BodySize.medium,
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isActive = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: BodyText(
          label,
          size: BodySize.small,
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  List<ArtisanBooking> _getFilteredBookings(List<ArtisanBooking> bookings) {
    final base = _mainTabIndex == 0
        ? bookings.where((booking) => booking.isUpcoming).toList()
        : bookings.where((booking) => booking.isHistory).toList();

    final now = DateTime.now();

    if (_mainTabIndex == 0) {
      final filter = _upcomingFilters[_filterIndex];
      if (filter == 'Pending') {
        return base
            .where((booking) => booking.status == ArtisanBookingStatus.pending)
            .toList();
      }
      if (filter == 'Accepted') {
        return base
            .where(
              (booking) =>
                  booking.status == ArtisanBookingStatus.accepted ||
                  booking.status == ArtisanBookingStatus.paid,
            )
            .toList();
      }
      if (filter == 'Today') {
        return base
            .where(
              (booking) =>
                  booking.jobDate.year == now.year &&
                  booking.jobDate.month == now.month &&
                  booking.jobDate.day == now.day,
            )
            .toList();
      }
      return base;
    }

    final filter = _historyFilters[_filterIndex];
    if (filter == 'Completed') {
      return base
          .where((booking) => booking.status == ArtisanBookingStatus.completed)
          .toList();
    }
    if (filter == 'Cancelled') {
      return base
          .where((booking) => booking.status == ArtisanBookingStatus.cancelled)
          .toList();
    }
    if (filter == 'Rejected') {
      return base
          .where((booking) => booking.status == ArtisanBookingStatus.rejected)
          .toList();
    }

    return base;
  }

  Widget _buildHistorySummary(List<ArtisanBooking> bookings) {
    final history = bookings.where(
      (booking) => booking.status == ArtisanBookingStatus.completed,
    );
    final totalEarned = history.fold<double>(
      0,
      (sum, booking) => sum + (booking.agreedAmount ?? booking.budgetMin),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BodyText(
                'Total Earned: ',
                size: BodySize.medium,
                fontWeight: FontWeight.w500,
              ),
              BodyText(
                formatNaira(totalEarned),
                size: BodySize.medium,
                color: const Color(0xFFE2725B),
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          BodyText(
            'From ${history.length} jobs',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, ArtisanBooking booking) {
    final clientName = booking.customerName ?? 'Client';
    final serviceName = booking.serviceName ?? 'Service Request';
    final avatar = booking.customerProfilePictureUrl ?? '';

    final neededServices = <String>[
      if (booking.jobDescription != null &&
          booking.jobDescription!.trim().isNotEmpty)
        booking.jobDescription!.trim(),
    ];

    final timeInfo = _formatDateTime(booking.jobDate);

    switch (booking.status) {
      case ArtisanBookingStatus.pending:
        return ArtisanJobCard(
          status: ArtisanJobStatus.pending,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatBudget(booking),
          timeInfo: timeInfo,
          neededServices: neededServices,
          primaryActionLabel: 'Accept',
          secondaryActionLabel: 'Reject',
          onActionPressed: () => _onAcceptPressed(booking),
          onSecondaryActionPressed: () => _onRejectPressed(booking),
          onPhonePressed: null,
          onDirectionsPressed: () => _openDirections(booking),
          negotiationSummary: _negotiationSummary(booking),
          onCardTap: () => _openBookingDetail(booking),
        );

      case ArtisanBookingStatus.accepted:
        return ArtisanJobCard(
          status: ArtisanJobStatus.next,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatAgreedAmount(booking),
          timeInfo: timeInfo,
          headerLabel: 'ACCEPTED',
          headerTimeInfo: 'Awaiting payment',
          primaryActionLabel: 'View Details',
          neededServices: neededServices,
          onActionPressed: () => _openBookingDetail(booking),
          onPhonePressed: () => _callClient(booking),
          onDirectionsPressed: () => _openDirections(booking),
          onCardTap: () => _openBookingDetail(booking),
        );

      case ArtisanBookingStatus.paid:
        return ArtisanJobCard(
          status: ArtisanJobStatus.next,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatAgreedAmount(booking),
          timeInfo: timeInfo,
          headerLabel: 'PAID JOB',
          headerTimeInfo: 'Ready to start',
          primaryActionLabel: 'Start Job',
          neededServices: neededServices,
          onActionPressed: () => _onStartPressed(booking),
          onPhonePressed: () => _callClient(booking),
          onDirectionsPressed: () => _openDirections(booking),
          onCardTap: () => _openBookingDetail(booking),
        );

      case ArtisanBookingStatus.inProgress:
        return ArtisanJobCard(
          status: ArtisanJobStatus.ongoing,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatAgreedAmount(booking),
          timeInfo: timeInfo,
          primaryActionLabel: 'Continue Job',
          neededServices: neededServices,
          onActionPressed: () => _openBookingDetail(booking),
          onPhonePressed: () => _callClient(booking),
          onDirectionsPressed: () => _openDirections(booking),
          onCardTap: () => _openBookingDetail(booking),
        );

      case ArtisanBookingStatus.completed:
        return ArtisanJobCard(
          status: ArtisanJobStatus.completed,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatAgreedAmount(booking),
          timeInfo: timeInfo,
          primaryActionLabel: 'View Details',
          neededServices: neededServices,
          onActionPressed: () => _openBookingDetail(booking),
          onPhonePressed: () => _callClient(booking),
          onCardTap: () => _openBookingDetail(booking),
        );

      case ArtisanBookingStatus.rejected:
        return ArtisanJobCard(
          status: ArtisanJobStatus.cancelled,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatBudget(booking),
          timeInfo: timeInfo,
          primaryActionLabel: 'View Details',
          statusTagLabel: 'Rejected',
          neededServices: neededServices,
          onActionPressed: () => _openBookingDetail(booking),
          onPhonePressed: () => _callClient(booking),
          onCardTap: () => _openBookingDetail(booking),
        );

      case ArtisanBookingStatus.cancelled:
      case ArtisanBookingStatus.disputed:
      case ArtisanBookingStatus.unknown:
        return ArtisanJobCard(
          status: ArtisanJobStatus.cancelled,
          serviceName: serviceName,
          clientName: clientName,
          clientAvatar: avatar,
          price: _formatBudget(booking),
          timeInfo: timeInfo,
          primaryActionLabel: 'View Details',
          statusTagLabel: booking.status == ArtisanBookingStatus.disputed
              ? 'Disputed'
              : null,
          neededServices: neededServices,
          onActionPressed: () => _openBookingDetail(booking),
          onPhonePressed: () => _callClient(booking),
          onCardTap: () => _openBookingDetail(booking),
        );
    }
  }

  Future<void> _onAcceptPressed(ArtisanBooking booking) async {
    double? agreedAmount;
    final negotiationDriven =
        booking.negotiatedAmount != null &&
        (booking.negotiationStatus == 'pending_artisan' ||
            booking.negotiationStatus == 'agreed');
    if (negotiationDriven) {
      agreedAmount = booking.negotiatedAmount;
    } else {
      agreedAmount = await _showAmountInputDialog(booking);
      if (agreedAmount == null) {
        return;
      }
    }

    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .acceptBooking(bookingId: booking.id, agreedAmount: agreedAmount!);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking accepted successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(e))));
    }
  }

  Future<void> _onRejectPressed(ArtisanBooking booking) async {
    final reason = await _showTextInputDialog(
      title: 'Reject Booking',
      hint: 'Enter rejection reason',
      minLength: 10,
    );

    if (reason == null) {
      return;
    }

    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .rejectBooking(bookingId: booking.id, rejectionReason: reason);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking rejected')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(e))));
    }
  }

  Future<void> _onStartPressed(ArtisanBooking booking) async {
    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .startBooking(bookingId: booking.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job started')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(e))));
    }
  }

  void _openBookingDetail(ArtisanBooking booking) {
    context.push(AppRoutes.jobDetail, extra: booking);
  }

  Future<void> _callClient(ArtisanBooking booking) async {
    final phone = booking.customerPhoneNumber;
    if (phone == null || phone.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client phone number is not available')),
      );
      return;
    }

    final launched = await launchPhoneDialer(phone);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open dialer')));
    }
  }

  Future<void> _openDirections(ArtisanBooking booking) async {
    Uri mapUri;

    if (booking.jobLatitude != null && booking.jobLongitude != null) {
      mapUri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '${booking.jobLatitude},${booking.jobLongitude}',
        'travelmode': 'driving',
      });
    } else {
      final address = booking.jobAddress.trim();
      if (address.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job location is not available')),
        );
        return;
      }

      mapUri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': address,
        'travelmode': 'driving',
      });
    }

    final launched = await launchUrl(
      mapUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open Google Maps')),
      );
    }
  }

  String _formatBudget(ArtisanBooking booking) {
    return '${formatNaira(booking.budgetMin)} - ${formatNaira(booking.budgetMax)}';
  }

  String _formatAgreedAmount(ArtisanBooking booking) {
    final amount = booking.agreedAmount;
    if (amount == null) {
      return _formatBudget(booking);
    }
    return formatNaira(amount);
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[local.weekday - 1]}, ${local.day} ${months[local.month - 1]}, ${local.year} • $hour:$minute $period';
  }

  String _negotiationSummary(ArtisanBooking booking) {
    final status = booking.negotiationStatus;
    final amount = booking.negotiatedAmount;
    final amountText = amount != null ? formatNaira(amount) : '';
    final rounds =
        'A${booking.artisanNegotiationRoundsUsed}/2 C${booking.clientNegotiationRoundsUsed}/2';

    switch (status) {
      case 'pending_client':
        return 'Offer $amountText sent • Awaiting client ($rounds)';
      case 'pending_artisan':
        return 'Client counter $amountText • Your response ($rounds)';
      case 'agreed':
        return 'Negotiated $amountText • Ready to accept';
      case 'declined':
        return 'Negotiation declined';
      default:
        return 'Tap to open and negotiate price.';
    }
  }

  Future<double?> _showAmountInputDialog(ArtisanBooking booking) async {
    final controller = TextEditingController(
      text: (((booking.budgetMin + booking.budgetMax) / 2)).toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Accept Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set amount between ${formatNaira(booking.budgetMin)} and ${formatNaira(booking.budgetMax)}',
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Agreed amount',
                  prefixText: '₦ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                if (amount == null) {
                  return;
                }
                Navigator.pop(context, amount);
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String hint,
    int minLength = 1,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.length < minLength) {
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }
}
