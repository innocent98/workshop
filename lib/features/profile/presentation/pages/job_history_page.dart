import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../bookings/domain/models/artisan_booking.dart';
import '../../../bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../../../core/widgets/common/error_state.dart';
import '../../../../core/utils/money_format.dart';

class JobHistoryPage extends ConsumerStatefulWidget {
  const JobHistoryPage({super.key});

  @override
  ConsumerState<JobHistoryPage> createState() => _JobHistoryPageState();
}

class _JobHistoryPageState extends ConsumerState<JobHistoryPage> {
  int _filterIndex = 0;
  final List<String> _filters = ['All', 'Completed', 'Cancelled', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(artisanBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: BodyText(
          'Job History',
          size: BodySize.large,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 36.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filters.length,
              itemBuilder: (context, index) => _buildFilterChip(index),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: historyAsync.when(
              data: (bookings) {
                final filtered = _filterHistory(bookings);
                if (filtered.isEmpty) {
                  return Center(
                    child: BodyText(
                      'No history found',
                      size: BodySize.medium,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.read(artisanBookingsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemBuilder: (context, index) =>
                        _buildHistoryCard(filtered[index]),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemCount: filtered.length,
                  ),
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, _) => ErrorState(
                error: error,
                title: 'Could not load your job history',
                onRetry: () =>
                    ref.read(artisanBookingsProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index) {
    final isActive = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: BodyText(
            _filters[index],
            size: BodySize.small,
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<ArtisanBooking> _filterHistory(List<ArtisanBooking> bookings) {
    final history = bookings.where((booking) => booking.isHistory).toList();
    final filter = _filters[_filterIndex];

    if (filter == 'Completed') {
      return history
          .where((booking) => booking.status == ArtisanBookingStatus.completed)
          .toList();
    }
    if (filter == 'Cancelled') {
      return history
          .where((booking) => booking.status == ArtisanBookingStatus.cancelled)
          .toList();
    }
    if (filter == 'Rejected') {
      return history
          .where((booking) => booking.status == ArtisanBookingStatus.rejected)
          .toList();
    }
    return history;
  }

  Widget _buildHistoryCard(ArtisanBooking booking) {
    final counterpart = booking.customerName ?? booking.artisanName ?? 'User';
    final statusLabel = _statusLabel(booking.status);
    final jobDate = DateFormat('dd MMM yyyy, h:mm a').format(booking.jobDate);
    final amount = booking.agreedAmount ?? booking.budgetMax;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: BodyText(
                  booking.serviceName ?? 'Service Request',
                  size: BodySize.medium,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: BodyText(
                  statusLabel,
                  size: BodySize.small,
                  color: _statusColor(booking.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          BodyText(
            'With: $counterpart',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 4.h),
          BodyText(
            'Date: $jobDate',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 4.h),
          BodyText(
            'Amount: ${formatNaira(amount)}',
            size: BodySize.small,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  String _statusLabel(ArtisanBookingStatus status) {
    switch (status) {
      case ArtisanBookingStatus.completed:
        return 'Completed';
      case ArtisanBookingStatus.cancelled:
        return 'Cancelled';
      case ArtisanBookingStatus.rejected:
        return 'Rejected';
      case ArtisanBookingStatus.disputed:
        return 'Disputed';
      default:
        return 'History';
    }
  }

  Color _statusColor(ArtisanBookingStatus status) {
    switch (status) {
      case ArtisanBookingStatus.completed:
        return const Color(0xFF0B8F47);
      case ArtisanBookingStatus.cancelled:
      case ArtisanBookingStatus.rejected:
        return Colors.red;
      case ArtisanBookingStatus.disputed:
        return const Color(0xFF8A6D1A);
      default:
        return AppColors.textSecondary;
    }
  }
}
