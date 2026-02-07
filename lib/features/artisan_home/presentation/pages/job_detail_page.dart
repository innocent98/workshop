import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../bookings/domain/models/artisan_booking.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../domain/models/job_request.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  final dynamic job;

  const JobDetailPage({super.key, required this.job});

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.job is ArtisanBooking
        ? widget.job as ArtisanBooking
        : null;

    if (booking == null) {
      return _buildLegacyJobDetail(widget.job as JobRequest);
    }

    final detailState = ref.watch(artisanBookingDetailsProvider(booking.id));

    return detailState.when(
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: const Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: BodyText(
              error.toString(),
              size: BodySize.small,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (item) => _buildBookingDetail(item),
    );
  }

  Widget _buildBookingDetail(ArtisanBooking booking) {
    final lat = booking.jobLatitude ?? 6.5244;
    final lng = booking.jobLongitude ?? 3.3792;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyText(
                        booking.serviceName ?? 'Service Request',
                        size: BodySize.large,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBCCBCB),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: BodyText(
                          _statusLabel(booking.status),
                          size: BodySize.small,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BodyText(
                      _priceLabel(booking),
                      size: BodySize.large,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 4.h),
                    BodyText(
                      _timeOnly(booking.jobDate),
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            BodyText(
              _dateOnly(booking.jobDate),
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: _getAvatarImage(
                      booking.customerProfilePictureUrl ??
                          'assets/images/regular.jpg',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyText(
                          booking.customerName ?? 'Client',
                          size: BodySize.medium,
                          fontWeight: FontWeight.w500,
                        ),
                        BodyText(
                          'Booking Ref: ${booking.bookingReference}',
                          size: BodySize.small,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            BodyText(
              'Location',
              size: BodySize.medium,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 200.h,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(lat, lng),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.workchop.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 40.r,
                          height: 40.r,
                          child: Icon(
                            Icons.location_pin,
                            color: AppColors.primary,
                            size: 32.r,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            BodyText(
              booking.jobAddress,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 24.h),
            BodyText(
              'Details',
              size: BodySize.medium,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText(
                    'Description',
                    size: BodySize.small,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  BodyText(
                    booking.jobDescription?.trim().isNotEmpty == true
                        ? booking.jobDescription!
                        : 'No additional description provided.',
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  if (booking.rejectionReason != null) ...[
                    SizedBox(height: 12.h),
                    BodyText(
                      'Rejection Reason',
                      size: BodySize.small,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 4.h),
                    BodyText(
                      booking.rejectionReason!,
                      size: BodySize.small,
                      color: Colors.red,
                    ),
                  ],
                  if (booking.completionNotes != null) ...[
                    SizedBox(height: 12.h),
                    BodyText(
                      'Completion Notes',
                      size: BodySize.small,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 4.h),
                    BodyText(
                      booking.completionNotes!,
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 36.h),
            _buildActionSection(booking),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(ArtisanBooking booking) {
    if (_isSubmitting) {
      return SizedBox(
        width: double.infinity,
        height: 44.h,
        child: const Center(child: LoadingIndicator()),
      );
    }

    if (booking.status == ArtisanBookingStatus.pending) {
      return SizedBox(
        width: double.infinity,
        height: 44.h,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rejectBooking(booking),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2725B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: BodyText(
                  'Reject',
                  size: BodySize.medium,
                  color: const Color(0xFFE2725B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _acceptBooking(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: BodyText(
                  'Accept',
                  size: BodySize.medium,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (booking.status == ArtisanBookingStatus.paid) {
      return _primaryButton(
        text: 'Start Job',
        onPressed: () => _startBooking(booking),
        icon: Icons.play_circle_outline,
      );
    }

    if (booking.status == ArtisanBookingStatus.inProgress) {
      return _primaryButton(
        text: 'Complete Job',
        onPressed: () => _completeBooking(booking),
        icon: Icons.check_circle_outline,
      );
    }

    return _primaryButton(text: 'Done', onPressed: null, icon: Icons.check);
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.r, color: Colors.white),
            SizedBox(width: 8.w),
            BodyText(
              text,
              size: BodySize.medium,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildLegacyJobDetail(JobRequest job) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BodyText(
            'Legacy mock job: ${job.service}\nUse Artisan Jobs for live booking actions.',
            textAlign: TextAlign.center,
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: 20.r,
        ),
        onPressed: () => context.pop(),
      ),
      title: BodyText(
        'Job Details',
        size: BodySize.medium,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      centerTitle: true,
    );
  }

  Future<void> _acceptBooking(ArtisanBooking booking) async {
    final amount = await _showAmountDialog(booking);
    if (amount == null) {
      return;
    }

    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .acceptBooking(bookingId: booking.id, agreedAmount: amount);
    }, successMessage: 'Booking accepted');
  }

  Future<void> _rejectBooking(ArtisanBooking booking) async {
    final reason = await _showTextDialog(
      title: 'Reject Booking',
      hint: 'Reason for rejection',
      minLength: 10,
    );
    if (reason == null) {
      return;
    }

    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .rejectBooking(bookingId: booking.id, rejectionReason: reason);
    }, successMessage: 'Booking rejected');
  }

  Future<void> _startBooking(ArtisanBooking booking) async {
    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .startBooking(bookingId: booking.id);
    }, successMessage: 'Job started');
  }

  Future<void> _completeBooking(ArtisanBooking booking) async {
    final notes = await _showTextDialog(
      title: 'Complete Job',
      hint: 'Add completion notes (optional)',
      minLength: 0,
    );

    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .completeBooking(bookingId: booking.id, completionNotes: notes);
    }, successMessage: 'Job completed');
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
      final booking = widget.job is ArtisanBooking
          ? widget.job as ArtisanBooking
          : null;
      if (booking != null) {
        ref.invalidate(artisanBookingDetailsProvider(booking.id));
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<double?> _showAmountDialog(ArtisanBooking booking) async {
    final controller = TextEditingController(
      text: (((booking.budgetMin + booking.budgetMax) / 2)).toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Booking'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Agreed amount',
            helperText:
                'Between ₦${booking.budgetMin.toStringAsFixed(0)} and ₦${booking.budgetMax.toStringAsFixed(0)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null) {
                return;
              }
              Navigator.pop(context, value);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<String?> _showTextDialog({
    required String title,
    required String hint,
    int minLength = 1,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context, value.isEmpty ? null : value);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  ImageProvider _getAvatarImage(String avatar) {
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return NetworkImage(avatar);
    }
    return AssetImage(avatar);
  }

  String _statusLabel(ArtisanBookingStatus status) {
    switch (status) {
      case ArtisanBookingStatus.pending:
        return 'Pending';
      case ArtisanBookingStatus.accepted:
        return 'Accepted';
      case ArtisanBookingStatus.paid:
        return 'Paid';
      case ArtisanBookingStatus.inProgress:
        return 'In Progress';
      case ArtisanBookingStatus.completed:
        return 'Completed';
      case ArtisanBookingStatus.cancelled:
        return 'Cancelled';
      case ArtisanBookingStatus.rejected:
        return 'Rejected';
      case ArtisanBookingStatus.disputed:
        return 'Disputed';
      case ArtisanBookingStatus.unknown:
        return 'Unknown';
    }
  }

  String _priceLabel(ArtisanBooking booking) {
    final agreed = booking.agreedAmount;
    if (agreed != null) {
      return '₦${agreed.toStringAsFixed(0)}';
    }
    return '₦${booking.budgetMin.toStringAsFixed(0)} - ₦${booking.budgetMax.toStringAsFixed(0)}';
  }

  String _dateOnly(DateTime date) {
    final local = date.toLocal();
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
    return '${weekdays[local.weekday - 1]}, ${local.day} ${months[local.month - 1]}, ${local.year}';
  }

  String _timeOnly(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
