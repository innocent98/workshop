import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../../core/widgets/common/avatar_placeholder.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../bookings/domain/models/artisan_booking.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/widgets/common/error_state.dart';
import '../../../../core/utils/money_format.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  final ArtisanBooking job;

  const JobDetailPage({super.key, required this.job});

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  bool _isSubmitting = false;

  Future<void> _refreshBooking(int bookingId) async {
    await ref.read(artisanBookingsProvider.notifier).refresh();
    ref.invalidate(artisanBookingDetailsProvider(bookingId));
    await ref.read(artisanBookingDetailsProvider(bookingId).future);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.job;

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
        body: ErrorState(
          error: error,
          title: 'Could not load this job',
          onRetry: () =>
              ref.invalidate(artisanBookingDetailsProvider(booking.id)),
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
      body: RefreshIndicator(
        onRefresh: () => _refreshBooking(booking.id),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          children: [
            Column(
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
                        if (booking.negotiationStatus != 'none') ...[
                          SizedBox(height: 4.h),
                          BodyText(
                            '${_negotiationStatusLabel(booking.negotiationStatus)}'
                            '${booking.negotiatedAmount != null ? ' • ${formatNaira(booking.negotiatedAmount!)}' : ''}',
                            size: BodySize.small,
                            color: AppColors.textSecondary,
                          ),
                          BodyText(
                            'Rounds A${booking.artisanNegotiationRoundsUsed}/2 • C${booking.clientNegotiationRoundsUsed}/2',
                            size: BodySize.small,
                            color: AppColors.textSecondary,
                          ),
                        ],
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
                      ProfileAvatar(
                        imageUrl: booking.customerProfilePictureUrl,
                        name: booking.customerName,
                        radius: 24,
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
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 42.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _openDirections(booking),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.directions,
                      size: 16.r,
                      color: AppColors.primary,
                    ),
                    label: BodyText(
                      'Get Direction',
                      size: BodySize.small,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                if (_shouldShowProgressLogSection(booking)) ...[
                  SizedBox(height: 24.h),
                  BodyText(
                    'Progress Log',
                    size: BodySize.medium,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10.h),
                  _buildProgressLogSection(booking),
                ],
                SizedBox(height: 36.h),
                _buildActionSection(booking),
                SizedBox(height: 20.h),
              ],
            ),
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
      final canNegotiate = _canNegotiate(booking);
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
            if (canNegotiate) ...[
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _negotiateBooking(booking),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBCCBCB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: BodyText(
                    'Negotiate',
                    size: BodySize.small,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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

    if (booking.status == ArtisanBookingStatus.accepted) {
      return _primaryButton(
        text: 'Awaiting Client Payment',
        onPressed: null,
        icon: Icons.hourglass_bottom,
      );
    }

    if (booking.status == ArtisanBookingStatus.inProgress) {
      final canComplete = booking.progressLogs.isNotEmpty;
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: OutlinedButton.icon(
              onPressed: () => _logProgress(booking),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(
                Icons.edit_note_rounded,
                size: 16.r,
                color: AppColors.primary,
              ),
              label: BodyText(
                'Log Progress',
                size: BodySize.small,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _primaryButton(
            text: canComplete ? 'Complete Job' : 'Log Progress to Complete',
            onPressed: canComplete ? () => _completeBooking(booking) : null,
            icon: Icons.check_circle_outline,
          ),
        ],
      );
    }

    if (booking.status == ArtisanBookingStatus.completed) {
      if (booking.completionConfirmedByClientAt != null) {
        return _primaryButton(
          text: 'Completed',
          onPressed: null,
          icon: Icons.check_circle,
        );
      }
      return _primaryButton(
        text: 'Awaiting Client Confirmation',
        onPressed: null,
        icon: Icons.verified_outlined,
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
    double? amount;
    final negotiationDriven =
        booking.negotiatedAmount != null &&
        (booking.negotiationStatus == 'pending_artisan' ||
            booking.negotiationStatus == 'agreed');
    if (negotiationDriven) {
      amount = booking.negotiatedAmount;
    } else {
      amount = await _showAmountDialog(booking);
      if (amount == null) {
        return;
      }
    }

    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .acceptBooking(bookingId: booking.id, agreedAmount: amount!);
    }, successMessage: 'Booking accepted');
  }

  Future<void> _negotiateBooking(ArtisanBooking booking) async {
    final input = await showDialog<_NegotiationInput>(
      context: context,
      builder: (_) => _NegotiationDialog(booking: booking),
    );
    if (input == null) return;

    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .negotiateBooking(
            bookingId: booking.id,
            negotiatedAmount: input.amount,
            negotiationCondition: input.condition,
          );
    }, successMessage: 'Negotiation sent to client');
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
    if (booking.progressLogs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log at least one progress update before completion'),
        ),
      );
      return;
    }

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

  Future<void> _logProgress(ArtisanBooking booking) async {
    final input = await showModalBottomSheet<_ProgressLogInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogProgressDialog(),
    );
    if (input == null) return;

    await _runAction(() async {
      await ref
          .read(artisanBookingsProvider.notifier)
          .logProgress(
            bookingId: booking.id,
            description: input.description,
            imagePath: input.imagePath,
          );
    }, successMessage: 'Progress logged');
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

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
      ref.invalidate(artisanBookingDetailsProvider(widget.job.id));
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
      ).showSnackBar(SnackBar(content: Text(userMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<double?> _showAmountDialog(ArtisanBooking booking) async {
    return showDialog<double>(
      context: context,
      builder: (context) => _AcceptBookingDialog(booking: booking),
    );
  }

  bool _canNegotiate(ArtisanBooking booking) {
    if (booking.status != ArtisanBookingStatus.pending) {
      return false;
    }

    final status = booking.negotiationStatus;
    if (status == 'agreed' || status == 'declined') {
      return false;
    }

    if (booking.artisanNegotiationRoundsUsed >= 2 ||
        booking.clientNegotiationRoundsUsed >= 2) {
      return false;
    }

    return true;
  }

  bool _shouldShowProgressLogSection(ArtisanBooking booking) {
    if (booking.startedAt != null) return true;
    return booking.status == ArtisanBookingStatus.inProgress ||
        booking.status == ArtisanBookingStatus.completed ||
        booking.status == ArtisanBookingStatus.disputed;
  }

  Widget _buildProgressLogSection(ArtisanBooking booking) {
    final logs = booking.progressLogs;
    if (logs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: BodyText(
          'No progress logged yet. Add at least one update before completing this job.',
          size: BodySize.small,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: logs.map((log) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyText(
                _dateTimeLabel(log.createdAt),
                size: BodySize.small,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 6.h),
              BodyText(
                log.description,
                size: BodySize.small,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
              if ((log.imageUrl ?? '').trim().isNotEmpty) ...[
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    log.imageUrl!,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80.h,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: BodyText(
                        'Image unavailable',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<String?> _showTextDialog({
    required String title,
    required String hint,
    int minLength = 1,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          _TextInputDialog(title: title, hint: hint, minLength: minLength),
    );
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
      return formatNaira(agreed);
    }
    return '${formatNaira(booking.budgetMin)} - ${formatNaira(booking.budgetMax)}';
  }

  String _negotiationStatusLabel(String status) {
    switch (status) {
      case 'pending_client':
        return 'Negotiation: Awaiting client';
      case 'pending_artisan':
        return 'Negotiation: Client countered';
      case 'agreed':
        return 'Negotiation: Agreed';
      case 'declined':
        return 'Negotiation: Declined';
      default:
        return 'Negotiation';
    }
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

  String _dateTimeLabel(DateTime value) {
    return '${_dateOnly(value)} • ${_timeOnly(value)}';
  }
}

class _AcceptBookingDialog extends StatefulWidget {
  const _AcceptBookingDialog({required this.booking});

  final ArtisanBooking booking;

  @override
  State<_AcceptBookingDialog> createState() => _AcceptBookingDialogState();
}

class _ProgressLogInput {
  final String description;
  final String? imagePath;

  const _ProgressLogInput({required this.description, this.imagePath});
}

class _LogProgressDialog extends StatefulWidget {
  const _LogProgressDialog();

  @override
  State<_LogProgressDialog> createState() => _LogProgressDialogState();
}

class _LogProgressDialogState extends State<_LogProgressDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _selectedImage = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DEDE),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                const Text(
                  'Log Progress',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Progress Description',
                    hintText: 'Describe what has been completed so far',
                  ),
                ),
                SizedBox(height: 10.h),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _selectedImage == null
                        ? 'Add Image (Optional)'
                        : 'Image selected: ${_selectedImage!.name}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_error != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 11.sp, color: AppColors.error),
                  ),
                ],
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final description = _descriptionController.text
                              .trim();
                          if (description.length < 5) {
                            setState(
                              () => _error =
                                  'Description should be at least 5 characters',
                            );
                            return;
                          }
                          Navigator.of(context).pop(
                            _ProgressLogInput(
                              description: description,
                              imagePath: _selectedImage?.path,
                            ),
                          );
                        },
                        child: const Text(
                          'Save Progress',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcceptBookingDialogState extends State<_AcceptBookingDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (((widget.booking.budgetMin + widget.booking.budgetMax) / 2))
          .toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.92;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      title: const Text(
        'Accept Booking',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: width,
        child: TextField(
          controller: _controller,
          style: const TextStyle(fontSize: 13),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Agreed amount',
            labelStyle: const TextStyle(fontSize: 13),
            helperStyle: const TextStyle(fontSize: 11),
            helperText:
                'Between ${formatNaira(widget.booking.budgetMin)} and ${formatNaira(widget.booking.budgetMax)}',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(_controller.text.trim());
            if (value == null) return;
            Navigator.pop(context, value);
          },
          child: const Text('Accept', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class _NegotiationInput {
  final double amount;
  final String condition;

  const _NegotiationInput({required this.amount, required this.condition});
}

class _NegotiationDialog extends StatefulWidget {
  const _NegotiationDialog({required this.booking});

  final ArtisanBooking booking;

  @override
  State<_NegotiationDialog> createState() => _NegotiationDialogState();
}

class _NegotiationDialogState extends State<_NegotiationDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _conditionController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text:
          (widget.booking.negotiatedAmount ??
                  ((widget.booking.budgetMin + widget.booking.budgetMax) / 2))
              .toStringAsFixed(0),
    );
    _conditionController = TextEditingController(
      text: widget.booking.negotiationCondition ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rounds =
        'Rounds: Artisan ${widget.booking.artisanNegotiationRoundsUsed}/2 • Client ${widget.booking.clientNegotiationRoundsUsed}/2';
    return AlertDialog(
      title: const Text('Negotiate Price'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.86,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client range: ${formatNaira(widget.booking.budgetMin)} - ${formatNaira(widget.booking.budgetMax)}',
              ),
              SizedBox(height: 6.h),
              Text(rounds, style: TextStyle(fontSize: 11.sp)),
              SizedBox(height: 8.h),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Negotiated amount',
                  prefixText: '₦ ',
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _conditionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Condition for bargaining',
                  hintText: 'Explain why this amount is needed',
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim());
            final condition = _conditionController.text.trim();
            if (amount == null || amount <= 0) {
              setState(() => _error = 'Enter a valid amount');
              return;
            }
            if (condition.length < 5) {
              setState(
                () => _error = 'Condition should be at least 5 characters',
              );
              return;
            }
            Navigator.pop(
              context,
              _NegotiationInput(amount: amount, condition: condition),
            );
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.minLength,
  });

  final String title;
  final String hint;
  final int minLength;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        minLines: 3,
        maxLines: 5,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.length < widget.minLength) return;
            Navigator.pop(context, value.isEmpty ? null : value);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
