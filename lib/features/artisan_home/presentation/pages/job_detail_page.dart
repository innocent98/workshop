import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/job_request.dart';

class JobDetailPage extends StatelessWidget {
  final JobRequest job;

  const JobDetailPage({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: BodyText(
          'Job Details',
          size: BodySize.medium,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary, size: 24.r),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      job.service,
                      size: BodySize.large,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: job.type == JobType.scheduled
                            ? const Color(0xFFBCCBCB)
                            : const Color(0xFFFBE9E7),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: BodyText(
                        job.type == JobType.scheduled ? 'Scheduled' : 'Instant Service',
                        size: BodySize.small,
                        color: job.type == JobType.scheduled
                            ? AppColors.primary
                            : const Color(0xFFE2725B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BodyText(
                      '₦ 7,000',
                      size: BodySize.large,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 4.h),
                    BodyText(
                      '07:25 AM',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            BodyText(
              'Saturday, 27 Nov, 2025',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 24.h),

            // Client Card
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
                    backgroundImage: AssetImage(job.clientAvatar),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyText(
                          job.clientName,
                          size: BodySize.medium,
                          fontWeight: FontWeight.w500,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BodyText('Client: ', size: BodySize.small, color: AppColors.textSecondary),
                            BodyText(
                              job.clientName,
                              size: BodySize.small,
                              fontWeight: FontWeight.w500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // SizedBox(width: 2.w),
                            Icon(Icons.check_circle, size: 14.r, color: Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionCircle(Icons.chat_bubble_outline),
                      SizedBox(width: 6.w),
                      _buildActionCircle(Icons.phone_outlined),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Location Section
            BodyText('Location', size: BodySize.medium, fontWeight: FontWeight.w500),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 200.h,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(6.5244, 3.3792), // Lagos
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.workchop.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(6.5244, 3.3792),
                          width: 40.r,
                          height: 40.r,
                          child: CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 18.r,
                              backgroundImage: AssetImage(job.clientAvatar),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyText(
                        '34 Udosen Uko Street',
                        size: BodySize.large,
                        fontWeight: FontWeight.w500,
                      ),
                      BodyText(
                        '24km away',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions, size: 18.r, color: AppColors.textPrimary),
                      SizedBox(width: 4.w),
                      BodyText('Directions', size: BodySize.medium, fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Details Section
            BodyText('Details', size: BodySize.medium, fontWeight: FontWeight.w500),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14.r, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      BodyText('Mon, Dec 22', size: BodySize.small, color: AppColors.primary, fontWeight: FontWeight.w500),
                      const Spacer(),
                      Icon(Icons.access_time, size: 14.r, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      BodyText('Started 24 mins ago', size: BodySize.small, color: AppColors.primary, fontWeight: FontWeight.w500),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  BodyText('Description', size: BodySize.small, fontWeight: FontWeight.w500),
                  SizedBox(height: 4.h),
                  BodyText(
                    'I need a plumber to fix a constantly dripping faucet in my bathroom. The task involves inspecting the faucet to find the leak, replacing any worn-out parts like washers or cartridges, and ensuring it is completely watertight. Please clean up the work ar...',
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  SizedBox(height: 16.h),
                  BodyText('Needed Service', size: BodySize.small, fontWeight: FontWeight.w500),
                  SizedBox(height: 8.h),
                  _buildServiceItem('Door and Window Casing Installation'),
                  _buildServiceItem('Hardware Installation (Hinges, Drawer Slides, Locks)'),
                  _buildServiceItem('Advanced Wood Joinery'),
                ],
              ),
            ),
            SizedBox(height: 40.h),

            // Footer Button(s)
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: job.status == JobStatus.ongoing
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2725B)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: BodyText(
                              'Cancel Job',
                              size: BodySize.medium,
                              color: const Color(0xFFE2725B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: BodyText(
                              'Complete Job',
                              size: BodySize.medium,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {},
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
                          Icon(
                            Icons.play_circle_outline,
                            size: 18.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          BodyText(
                            'Start Job',
                            size: BodySize.medium,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFBCCBCB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 20.r),
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 16.r, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: BodyText(
              text,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
