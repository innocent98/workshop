import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../booking/data/booking_remote_datasource.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../domain/models/artisan_booking.dart';
import '../../domain/models/booking.dart';
import '../providers/artisan_bookings_provider.dart';
import '../widgets/completed_booking_card.dart';
import '../widgets/ongoing_booking_card.dart';
import '../widgets/request_booking_card.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage>
    with WidgetsBindingObserver {
  int _mainTabIndex = 0; // 0: Active, 1: History
  int _filterIndex = 0;
  final BookingRemoteDataSource _bookingRemoteDataSource =
      BookingRemoteDataSource();
  final PaymentRemoteDataSource _paymentRemoteDataSource =
      PaymentRemoteDataSource();
  final ReviewRemoteDataSource _reviewRemoteDataSource =
      ReviewRemoteDataSource();
  final Set<int> _reviewedBookingIds = <int>{};
  final Set<int> _reviewSubmittingBookingIds = <int>{};
  final Set<int> _paymentSubmittingBookingIds = <int>{};
  final Set<int> _confirmingCompletionBookingIds = <int>{};
  final Set<int> _negotiationSubmittingBookingIds = <int>{};
  final Map<int, String> _pendingPaymentReferences = <int, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyPendingPayments(autoTriggered: true);
    }
  }

  List<String> get _filters => _mainTabIndex == 0
      ? const ['All', 'Requested', 'Ongoing']
      : const ['All', 'Completed', 'Cancelled'];

  String _statusForUi(ArtisanBookingStatus status) {
    switch (status) {
      case ArtisanBookingStatus.pending:
      case ArtisanBookingStatus.accepted:
        return 'requested';
      case ArtisanBookingStatus.paid:
      case ArtisanBookingStatus.inProgress:
      case ArtisanBookingStatus.disputed:
        return 'ongoing';
      case ArtisanBookingStatus.completed:
        return 'completed';
      case ArtisanBookingStatus.cancelled:
      case ArtisanBookingStatus.rejected:
        return 'cancelled';
      case ArtisanBookingStatus.unknown:
        return 'requested';
    }
  }

  bool _canRateBooking(ArtisanBooking booking) {
    return booking.status == ArtisanBookingStatus.completed &&
        booking.completionConfirmedByClientAt != null &&
        booking.completionDisputedAt == null;
  }

  Booking _toUiBooking(ArtisanBooking booking) {
    final serviceLine = (booking.jobDescription ?? '').trim().isNotEmpty
        ? booking.jobDescription!.trim()
        : (booking.serviceName ?? 'Service request');
    return Booking(
      id: booking.id.toString(),
      artisanName: booking.artisanName ?? 'Artisan',
      artisanAvatar:
          booking.artisanProfilePictureUrl ??
          booking.serviceImage ??
          'assets/images/regular.jpg',
      serviceType: booking.serviceName ?? 'Service',
      isVerified: false,
      status: _statusForUi(booking.status),
      dateTime: booking.jobDate,
      services: [serviceLine],
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(artisanBookingsProvider.notifier).refresh();
  }

  Future<void> _openDetails(ArtisanBooking booking) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => _BookingDetailSheet(booking: booking),
    );
  }

  Future<void> _cancelRequestedBooking(String bookingId) async {
    final id = int.tryParse(bookingId);
    if (id == null) return;

    final cancellationReason = await _promptCancellationReason();
    if (cancellationReason == null) return;

    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .cancelBooking(bookingId: id, cancellationReason: cancellationReason);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateRequestedBooking(ArtisanBooking booking) async {
    if (booking.status != ArtisanBookingStatus.pending) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Only pending requests can be updated. Cancel and rebook for accepted jobs.',
          ),
        ),
      );
      return;
    }

    if (booking.jobLatitude == null || booking.jobLongitude == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This booking does not have a valid location. Please create a new booking instead.',
          ),
        ),
      );
      return;
    }

    final updated = await _promptUpdateRequest(booking);
    if (updated == null) return;

    try {
      await _bookingRemoteDataSource.createBooking(
        artisanId: booking.artisanId,
        serviceIds: [booking.serviceId],
        jobDateUtc: updated.jobDateLocal.toUtc(),
        jobAddress: booking.jobAddress,
        jobLatitude: booking.jobLatitude!,
        jobLongitude: booking.jobLongitude!,
        budgetMin: updated.budgetMin,
        budgetMax: updated.budgetMax,
        jobDescription: updated.jobDescription,
      );

      await ref
          .read(artisanBookingsProvider.notifier)
          .cancelBooking(
            bookingId: booking.id,
            cancellationReason: updated.cancellationReason,
          );

      await ref.read(artisanBookingsProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<_UpdateBookingInput?> _promptUpdateRequest(
    ArtisanBooking booking,
  ) async {
    return showDialog<_UpdateBookingInput>(
      context: context,
      builder: (_) => _UpdateBookingDialog(
        initialDateTime: booking.jobDate.toLocal(),
        initialNote: booking.jobDescription ?? '',
        initialBudgetMin: booking.budgetMin.toStringAsFixed(0),
        initialBudgetMax: booking.budgetMax.toStringAsFixed(0),
        initialCancellationReason: 'Updating booking request details',
      ),
    );
  }

  Future<void> _rateBooking(ArtisanBooking booking) async {
    if (!_canRateBooking(booking)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can rate only after completion has been confirmed.',
          ),
        ),
      );
      return;
    }

    if (_reviewedBookingIds.contains(booking.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review already submitted for this job')),
      );
      return;
    }

    final input = await _promptReviewDetails();
    if (input == null) return;

    setState(() => _reviewSubmittingBookingIds.add(booking.id));
    try {
      await _reviewRemoteDataSource.createReview(
        bookingId: booking.id,
        rating: input.rating,
        reviewText: input.reviewText,
        isAnonymous: input.isAnonymous,
      );

      setState(() {
        _reviewSubmittingBookingIds.remove(booking.id);
        _reviewedBookingIds.add(booking.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review submitted')));
    } catch (e) {
      final alreadyReviewed =
          e is ApiException &&
          e.message.toLowerCase().contains('review already exists');

      if (alreadyReviewed) {
        setState(() {
          _reviewSubmittingBookingIds.remove(booking.id);
          _reviewedBookingIds.add(booking.id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review was already submitted')),
        );
        return;
      }

      setState(() => _reviewSubmittingBookingIds.remove(booking.id));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _payForAcceptedBooking(ArtisanBooking booking) async {
    if (_paymentSubmittingBookingIds.contains(booking.id)) return;

    setState(() => _paymentSubmittingBookingIds.add(booking.id));
    try {
      final init = await _paymentRemoteDataSource.initializePayment(
        bookingId: booking.id,
      );
      final checkoutUrl = Uri.tryParse(init.authorizationUrl);
      if (checkoutUrl == null) {
        throw ApiException('Invalid payment checkout URL');
      }

      final launched = await launchUrl(
        checkoutUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw ApiException('Unable to open payment checkout');
      }

      _pendingPaymentReferences[booking.id] = init.paymentReference;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Complete payment in checkout and return to app. Verification runs automatically.',
          ),
          action: SnackBarAction(
            label: 'Verify now',
            onPressed: () {
              _verifyPendingPayments(autoTriggered: false);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _paymentSubmittingBookingIds.remove(booking.id));
      }
    }
  }

  Future<void> _callArtisan(ArtisanBooking booking) async {
    final phone = booking.artisanPhoneNumber?.trim() ?? '';
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artisan phone number is not available')),
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

  Future<void> _verifyPendingPayments({required bool autoTriggered}) async {
    if (_pendingPaymentReferences.isEmpty) return;

    final pending = _pendingPaymentReferences.entries.toList();
    bool paidAny = false;

    for (final entry in pending) {
      try {
        final verify = await _paymentRemoteDataSource.verifyPayment(
          paymentReference: entry.value,
        );
        if (verify.paid) {
          _pendingPaymentReferences.remove(entry.key);
          paidAny = true;
        }
      } catch (_) {
        // Keep pending for next retry.
      }
    }

    if (!mounted) return;
    if (paidAny) {
      await ref.read(artisanBookingsProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment verified. Booking updated to paid'),
        ),
      );
      return;
    }

    if (!autoTriggered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment not verified yet. Try again shortly.'),
        ),
      );
    }
  }

  Future<void> _confirmJobCompletion(ArtisanBooking booking) async {
    if (_confirmingCompletionBookingIds.contains(booking.id)) return;

    setState(() => _confirmingCompletionBookingIds.add(booking.id));
    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .confirmCompletion(bookingId: booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job completion confirmed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _confirmingCompletionBookingIds.remove(booking.id));
      }
    }
  }

  Future<_ReviewInput?> _promptReviewDetails() async {
    return showDialog<_ReviewInput>(
      context: context,
      builder: (_) => const _ReviewDialog(),
    );
  }

  Future<String?> _promptCancellationReason() async {
    return showDialog<String>(
      context: context,
      builder: (_) => const _CancelBookingDialog(),
    );
  }

  Future<void> _respondToNegotiation(ArtisanBooking booking) async {
    if (_negotiationSubmittingBookingIds.contains(booking.id)) return;

    final decision = await showDialog<_NegotiationDecision>(
      context: context,
      builder: (_) => _NegotiationDecisionDialog(booking: booking),
    );
    if (decision == null) return;

    setState(() => _negotiationSubmittingBookingIds.add(booking.id));
    BuildContext? progressDialogContext;
    if (mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          progressDialogContext = ctx;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    try {
      await ref
          .read(artisanBookingsProvider.notifier)
          .respondToNegotiation(
            bookingId: booking.id,
            action: decision.action,
            negotiatedAmount: decision.amount,
            negotiationCondition: decision.condition,
          );

      if (!mounted) return;
      final msg = switch (decision.action) {
        'agree' => 'Negotiation accepted. Waiting for artisan acceptance.',
        'counter' => 'Counter-offer sent to artisan.',
        _ => 'Negotiation declined. Booking cancelled.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        if (progressDialogContext != null && progressDialogContext!.mounted) {
          Navigator.of(progressDialogContext!).pop();
        }
        setState(() => _negotiationSubmittingBookingIds.remove(booking.id));
      }
    }
  }

  List<Widget> _buildActiveList(List<ArtisanBooking> bookings) {
    final active = bookings
        .where(
          (b) =>
              _statusForUi(b.status) == 'ongoing' ||
              _statusForUi(b.status) == 'requested',
        )
        .toList();

    final filtered = switch (_filterIndex) {
      1 => active.where((b) => _statusForUi(b.status) == 'requested').toList(),
      2 => active.where((b) => _statusForUi(b.status) == 'ongoing').toList(),
      _ => active,
    };

    if (filtered.isEmpty) {
      return [
        SizedBox(height: 120.h),
        const Center(
          child: BodyText(
            'No active bookings yet',
            size: BodySize.medium,
            color: AppColors.textSecondary,
          ),
        ),
      ];
    }

    return filtered.map((item) {
      final booking = _toUiBooking(item);
      if (_statusForUi(item.status) == 'ongoing') {
        return OngoingBookingCard(
          booking: booking,
          onTap: () => _openDetails(item),
          onCallTap: () => _callArtisan(item),
        );
      }
      if (item.status == ArtisanBookingStatus.accepted) {
        final processing = _paymentSubmittingBookingIds.contains(item.id);
        return RequestBookingCard(
          booking: booking,
          onTap: () => _openDetails(item),
          secondaryActionLabel: 'Cancel',
          primaryActionLabel: processing ? 'Processing...' : 'Pay now',
          onSecondaryTap: () => _cancelRequestedBooking(item.id.toString()),
          onPrimaryTap: processing ? null : () => _payForAcceptedBooking(item),
          onCallTap: () => _callArtisan(item),
        );
      }
      return RequestBookingCard(
        booking: booking,
        onTap: () => _openDetails(item),
        onCancelTap: () => _cancelRequestedBooking(item.id.toString()),
        onUpdateTap: item.negotiationStatus == 'pending_client'
            ? (_negotiationSubmittingBookingIds.contains(item.id)
                  ? null
                  : () => _respondToNegotiation(item))
            : (item.negotiationStatus == 'pending_artisan'
                  ? null
                  : () => _updateRequestedBooking(item)),
        primaryActionLabel: item.negotiationStatus == 'pending_client'
            ? (_negotiationSubmittingBookingIds.contains(item.id)
                  ? 'Submitting...'
                  : 'Respond Offer')
            : (item.negotiationStatus == 'pending_artisan'
                  ? 'Awaiting Artisan'
                  : null),
      );
    }).toList();
  }

  List<Widget> _buildHistoryList(List<ArtisanBooking> bookings) {
    final history = bookings
        .where(
          (b) =>
              _statusForUi(b.status) == 'completed' ||
              _statusForUi(b.status) == 'cancelled',
        )
        .toList();

    final filtered = switch (_filterIndex) {
      1 => history.where((b) => _statusForUi(b.status) == 'completed').toList(),
      2 => history.where((b) => _statusForUi(b.status) == 'cancelled').toList(),
      _ => history,
    };

    if (filtered.isEmpty) {
      return [
        SizedBox(height: 120.h),
        const Center(
          child: BodyText(
            'No booking history yet',
            size: BodySize.medium,
            color: AppColors.textSecondary,
          ),
        ),
      ];
    }

    return filtered.map((item) {
      final booking = _toUiBooking(item);
      final isCompleted = _statusForUi(item.status) == 'completed';
      final canRate = _canRateBooking(item);
      final needsClientConfirmation =
          isCompleted &&
          item.completionConfirmedByClientAt == null &&
          item.completionDisputedAt == null;
      final confirming = _confirmingCompletionBookingIds.contains(item.id);
      return CompletedBookingCard(
        booking: booking,
        onTap: () => _openDetails(item),
        onDeleteTap: needsClientConfirmation
            ? (confirming ? null : () => _confirmJobCompletion(item))
            : () => _openDetails(item),
        secondaryActionLabel: needsClientConfirmation
            ? (confirming ? 'Confirming...' : 'Confirm Job Completion')
            : 'View Details',
        onRateTap: canRate ? () => _rateBooking(item) : null,
        isReviewSubmitted: canRate && _reviewedBookingIds.contains(item.id),
        isSubmittingReview:
            canRate && _reviewSubmittingBookingIds.contains(item.id),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(artisanBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: BodyText(
          'Bookings',
          size: BodySize.large,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    _buildMainTab('Active', 0),
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
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  return _buildFilterChip(_filters[index], index);
                },
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: bookingsAsync.when(
                data: (liveBookings) {
                  final items = _mainTabIndex == 0
                      ? _buildActiveList(liveBookings)
                      : _buildHistoryList(liveBookings);

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: items,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BodyText(
                        'Failed to load bookings',
                        size: BodySize.medium,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => ref
                            .read(artisanBookingsProvider.notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                      SizedBox(height: 6.h),
                      BodyText(
                        error.toString(),
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
}

class _BookingDetailSheet extends StatelessWidget {
  final ArtisanBooking booking;

  const _BookingDetailSheet({required this.booking});

  String _prettyStatus(ArtisanBookingStatus status) {
    switch (status) {
      case ArtisanBookingStatus.inProgress:
        return 'In Progress';
      case ArtisanBookingStatus.paid:
        return 'Paid';
      case ArtisanBookingStatus.pending:
        return 'Pending';
      case ArtisanBookingStatus.accepted:
        return 'Accepted';
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

  String _money(double value) => '₦${value.toStringAsFixed(0)}';

  bool _shouldShowProgressLogs(ArtisanBooking booking) {
    if (booking.startedAt != null) return true;
    return booking.status == ArtisanBookingStatus.inProgress ||
        booking.status == ArtisanBookingStatus.completed ||
        booking.status == ArtisanBookingStatus.disputed;
  }

  _PaymentBadge _paymentBadgeForStatus(ArtisanBookingStatus status) {
    switch (status) {
      case ArtisanBookingStatus.accepted:
        return const _PaymentBadge(
          label: 'Pending payment',
          backgroundColor: Color(0xFFFFF6E5),
          textColor: Color(0xFF8A5A00),
          icon: Icons.schedule,
        );
      case ArtisanBookingStatus.paid:
      case ArtisanBookingStatus.inProgress:
      case ArtisanBookingStatus.completed:
        return const _PaymentBadge(
          label: 'Payment completed',
          backgroundColor: Color(0xFFE9F8EE),
          textColor: Color(0xFF1D7A38),
          icon: Icons.check_circle,
        );
      default:
        return const _PaymentBadge(
          label: 'Payment unavailable',
          backgroundColor: Color(0xFFF1F3F5),
          textColor: Color(0xFF5C6670),
          icon: Icons.info_outline,
        );
    }
  }

  void _openProgressImage(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: BodyText(
                        'Unable to load image',
                        size: BodySize.small,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16.h,
              right: 16.w,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Colors.white, size: 22.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'EEE, d MMM yyyy • hh:mm a',
    ).format(booking.jobDate);
    final paymentBadge = _paymentBadgeForStatus(booking.status);
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyText(
                'Booking Details',
                size: BodySize.large,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 10.h),
              BodyText(
                'Ref: ${booking.bookingReference}',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 10.h),
              BodyText(
                booking.serviceName ?? 'Service',
                size: BodySize.medium,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 6.h),
              BodyText(
                booking.jobDescription ?? 'No description provided',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 10.h),
              BodyText('Date: $date', size: BodySize.small),
              SizedBox(height: 4.h),
              BodyText(
                'Status: ${_prettyStatus(booking.status)}',
                size: BodySize.small,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: paymentBadge.backgroundColor,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      paymentBadge.icon,
                      size: 13.r,
                      color: paymentBadge.textColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      paymentBadge.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: paymentBadge.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              BodyText('Address: ${booking.jobAddress}', size: BodySize.small),
              SizedBox(height: 4.h),
              BodyText(
                'Budget: ${_money(booking.budgetMin)} - ${_money(booking.budgetMax)}',
                size: BodySize.small,
              ),
              if (booking.negotiatedAmount != null) ...[
                SizedBox(height: 4.h),
                BodyText(
                  'Negotiated: ${_money(booking.negotiatedAmount!)}',
                  size: BodySize.small,
                ),
                if ((booking.negotiationCondition ?? '').trim().isNotEmpty)
                  BodyText(
                    'Condition: ${booking.negotiationCondition}',
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                  ),
                BodyText(
                  'Rounds — Artisan ${booking.artisanNegotiationRoundsUsed}/2 • Client ${booking.clientNegotiationRoundsUsed}/2',
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                ),
              ],
              if (booking.agreedAmount != null) ...[
                SizedBox(height: 4.h),
                BodyText(
                  'Agreed: ${_money(booking.agreedAmount!)}',
                  size: BodySize.small,
                ),
              ],
              if (_shouldShowProgressLogs(booking)) ...[
                SizedBox(height: 12.h),
                BodyText(
                  'Progress Log',
                  size: BodySize.small,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6.h),
                if (booking.progressLogs.isEmpty)
                  BodyText(
                    'No progress updates yet.',
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                  )
                else
                  ...booking.progressLogs.map(
                    (log) => Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyText(
                            DateFormat(
                              'EEE, d MMM yyyy • hh:mm a',
                            ).format(log.createdAt.toLocal()),
                            size: BodySize.small,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 4.h),
                          BodyText(log.description, size: BodySize.small),
                          if ((log.imageUrl ?? '').trim().isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () =>
                                  _openProgressImage(context, log.imageUrl!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  log.imageUrl!,
                                  height: 120.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NegotiationDecision {
  final String action;
  final double? amount;
  final String? condition;

  const _NegotiationDecision({
    required this.action,
    this.amount,
    this.condition,
  });
}

class _NegotiationDecisionDialog extends StatefulWidget {
  final ArtisanBooking booking;

  const _NegotiationDecisionDialog({required this.booking});

  @override
  State<_NegotiationDecisionDialog> createState() =>
      _NegotiationDecisionDialogState();
}

class _NegotiationDecisionDialogState
    extends State<_NegotiationDecisionDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _conditionController;
  bool _counterMode = false;
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
    _conditionController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offered = widget.booking.negotiatedAmount;
    final rounds =
        'Rounds: Artisan ${widget.booking.artisanNegotiationRoundsUsed}/2 • Client ${widget.booking.clientNegotiationRoundsUsed}/2';
    return AlertDialog(
      title: const Text('Price Negotiation'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.86,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offered == null
                    ? 'Artisan sent a new offer.'
                    : 'Artisan offered ₦${offered.toStringAsFixed(0)}',
              ),
              SizedBox(height: 6.h),
              Text(rounds, style: TextStyle(fontSize: 11.sp)),
              if ((widget.booking.negotiationCondition ?? '')
                  .trim()
                  .isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'Reason: ${widget.booking.negotiationCondition}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_counterMode) ...[
                SizedBox(height: 8.h),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Your counter amount',
                    prefixText: '₦ ',
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _conditionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your condition',
                    hintText: 'Explain your counter offer',
                  ),
                ),
              ],
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
        if (!_counterMode)
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              const _NegotiationDecision(action: 'decline'),
            ),
            child: const Text('Decline'),
          ),
        if (!_counterMode)
          TextButton(
            onPressed: () {
              setState(() {
                _counterMode = true;
                _error = null;
              });
            },
            child: const Text('Counter'),
          ),
        if (_counterMode)
          TextButton(
            onPressed: () {
              setState(() {
                _counterMode = false;
                _error = null;
              });
            },
            child: const Text('Back'),
          ),
        ElevatedButton(
          onPressed: () {
            if (!_counterMode) {
              Navigator.pop(
                context,
                const _NegotiationDecision(action: 'agree'),
              );
              return;
            }
            final amount = double.tryParse(_amountController.text.trim());
            final condition = _conditionController.text.trim();
            if (amount == null || amount <= 0) {
              setState(() => _error = 'Enter a valid counter amount');
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
              _NegotiationDecision(
                action: 'counter',
                amount: amount,
                condition: condition,
              ),
            );
          },
          child: Text(_counterMode ? 'Send Counter' : 'Agree'),
        ),
      ],
    );
  }
}

class _UpdateBookingDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final String initialNote;
  final String initialBudgetMin;
  final String initialBudgetMax;
  final String initialCancellationReason;

  const _UpdateBookingDialog({
    required this.initialDateTime,
    required this.initialNote,
    required this.initialBudgetMin,
    required this.initialBudgetMax,
    required this.initialCancellationReason,
  });

  @override
  State<_UpdateBookingDialog> createState() => _UpdateBookingDialogState();
}

class _UpdateBookingDialogState extends State<_UpdateBookingDialog> {
  late DateTime _selectedDateTime;
  late final TextEditingController _noteController;
  late final TextEditingController _budgetMinController;
  late final TextEditingController _budgetMaxController;
  late final TextEditingController _cancellationReasonController;
  String? _localError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateTime = widget.initialDateTime.isAfter(now)
        ? widget.initialDateTime
        : now.add(const Duration(hours: 1));
    _noteController = TextEditingController(text: widget.initialNote);
    _budgetMinController = TextEditingController(text: widget.initialBudgetMin);
    _budgetMaxController = TextEditingController(text: widget.initialBudgetMax);
    _cancellationReasonController = TextEditingController(
      text: widget.initialCancellationReason,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _cancellationReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    final min = double.tryParse(_budgetMinController.text.trim());
    final max = double.tryParse(_budgetMaxController.text.trim());
    final reason = _cancellationReasonController.text.trim();
    final note = _noteController.text.trim();

    if (_selectedDateTime.isBefore(
      DateTime.now().add(const Duration(minutes: 2)),
    )) {
      setState(() => _localError = 'Please select a future date/time');
      return;
    }

    if (min == null || max == null || min < 0 || max < 0) {
      setState(() => _localError = 'Enter valid budget values');
      return;
    }

    if (max < min) {
      setState(
        () => _localError = 'Budget max must be greater than budget min',
      );
      return;
    }

    if (reason.length < 10) {
      setState(
        () =>
            _localError = 'Cancellation reason must be at least 10 characters',
      );
      return;
    }

    Navigator.of(context).pop(
      _UpdateBookingInput(
        jobDateLocal: _selectedDateTime,
        jobDescription: note.isEmpty ? null : note,
        budgetMin: min,
        budgetMax: max,
        cancellationReason: reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.of(context).size.width * 0.94;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth > 560 ? 560 : dialogWidth,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_calendar_outlined,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                    SizedBox(width: 8.w),
                    const Expanded(
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                const Text(
                  'Edit schedule, note, and budget. A new request will be created and the current one cancelled.',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scheduled Date & Time',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      OutlinedButton.icon(
                        onPressed: _pickDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat(
                            'EEE, d MMM yyyy • hh:mm a',
                          ).format(_selectedDateTime),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Additional Note',
                    hintText: 'Describe what changed...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetMinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget Min',
                          prefixText: '₦',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: _budgetMaxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget Max',
                          prefixText: '₦',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _cancellationReasonController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Cancellation Reason (for old request)',
                    hintText: 'Minimum 10 characters',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_localError != null) ...[
                  SizedBox(height: 10.h),
                  BodyText(
                    _localError!,
                    size: BodySize.small,
                    color: Colors.red,
                  ),
                ],
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 13),
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

class _CancelBookingDialog extends StatefulWidget {
  const _CancelBookingDialog();

  @override
  State<_CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<_CancelBookingDialog> {
  late final TextEditingController _controller;
  String? _localError;

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

  void _submit() {
    final reason = _controller.text.trim();
    if (reason.length < 10) {
      setState(() => _localError = 'Reason must be at least 10 characters');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.of(context).size.width * 0.92;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth > 500 ? 500 : dialogWidth,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: Colors.red.shade600,
                      size: 22.r,
                    ),
                    SizedBox(width: 8.w),
                    const Expanded(
                      child: Text(
                        'Cancel Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                const Text(
                  'Please provide a clear reason for cancellation (minimum 10 characters).',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Reason for cancellation',
                    errorText: _localError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Keep booking',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Cancel booking',
                          style: TextStyle(fontSize: 13),
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

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  double _rating = 5.0;
  bool _anonymous = false;
  String? _localError;
  late final TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _reviewController.text.trim();
    if (comment.length > 1000) {
      setState(() => _localError = 'Comment must be 1000 characters or less');
      return;
    }
    Navigator.of(context).pop(
      _ReviewInput(
        rating: _rating,
        reviewText: comment.isEmpty ? null : comment,
        isAnonymous: _anonymous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.of(context).size.width * 0.94;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth > 560 ? 560 : dialogWidth,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rate_rounded,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                    SizedBox(width: 8.w),
                    const Expanded(
                      child: Text(
                        'Rate Artisan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                const Text(
                  'How was the service?',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 10.h),
                DropdownButtonFormField<double>(
                  initialValue: _rating,
                  items: List.generate(9, (index) {
                    final value = 1.0 + (index * 0.5);
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.toStringAsFixed(1)),
                    );
                  }),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _rating = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _reviewController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.h),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _anonymous,
                  onChanged: (value) =>
                      setState(() => _anonymous = value ?? false),
                  title: const Text('Post anonymously'),
                ),
                if (_localError != null)
                  BodyText(
                    _localError!,
                    size: BodySize.small,
                    color: Colors.red,
                  ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Not now',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text(
                          'Submit Review',
                          style: TextStyle(fontSize: 13),
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

class _UpdateBookingInput {
  final DateTime jobDateLocal;
  final String? jobDescription;
  final double budgetMin;
  final double budgetMax;
  final String cancellationReason;

  const _UpdateBookingInput({
    required this.jobDateLocal,
    required this.jobDescription,
    required this.budgetMin,
    required this.budgetMax,
    required this.cancellationReason,
  });
}

class _ReviewInput {
  final double rating;
  final String? reviewText;
  final bool isAnonymous;

  const _ReviewInput({
    required this.rating,
    required this.reviewText,
    required this.isAnonymous,
  });
}

class _PaymentBadge {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const _PaymentBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}
