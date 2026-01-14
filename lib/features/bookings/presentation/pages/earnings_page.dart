import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BodyText(
          'Your Wallet',
          size: BodySize.large,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F5),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  BodyText(
                    'Available Balance',
                    size: BodySize.medium,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12.h),
                  BodyText(
                    '₦ 120,650.00',
                    size: BodySize.large,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 200.w,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: BodyText(
                        'Request Payout',
                        size: BodySize.medium,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Lifetime & Pending Row
            Row(
              children: [
                _buildSmallStatCard('Lifetime Earnings', '₦ 480,000'),
                SizedBox(width: 16.w),
                _buildSmallStatCard('Pending', '₦ 89,000'),
              ],
            ),
            SizedBox(height: 24.h),

            // Payout Method Section
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyText(
                        'Payout Method',
                        size: BodySize.medium,
                        fontWeight: FontWeight.w500,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: BodyText(
                          'Manage',
                          size: BodySize.small,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBCCBCB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_balance, size: 20.r, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyText(
                              'Zenith Bank',
                              size: BodySize.medium,
                              fontWeight: FontWeight.w500,
                            ),
                            BodyText(
                              'Yannic Bazeel | ****** 4921',
                              size: BodySize.small,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: const Color(0xFFE2725B), size: 20.r),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const Divider(),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14.r, color: const Color(0xFFE2725B)),
                      SizedBox(width: 8.w),
                      BodyText(
                        'Payments are secured and encrypted',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyText(
                  'Recent Activity',
                  size: BodySize.medium,
                  fontWeight: FontWeight.w500,
                ),
                GestureDetector(
                  onTap: () {},
                  child: BodyText(
                    'See all',
                    size: BodySize.small,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Activity List
            _buildActivityItem(
              'Plumbing Repair',
              'Yannic Bazeel | 1 hour ago',
              '+ ₦ 50,000',
              'Credit',
              isCredit: true,
            ),
            _buildActivityItem(
              'Transfer to Bank',
              'Yesterday, 2:45pm',
              '- ₦ 20,000',
              'Payout',
              isCredit: false,
            ),
            _buildActivityItem(
              'Kitchen Cabinet Install',
              'Fatima Atiku | Dec 13, 11:15am',
              '+ ₦ 245,000',
              'Credit',
              isCredit: true,
            ),
            _buildActivityItem(
              'Faucet Replacement',
              'Promise Eyo | Dec 01, 9:08pm',
              '+ ₦ 245,000',
              'Credit',
              isCredit: true,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText(
              label,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            BodyText(
              value,
              size: BodySize.medium,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String amount, String type, {required bool isCredit}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: const AssetImage('assets/images/regular.jpg'), // Mock image
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      title,
                      size: BodySize.medium,
                      fontWeight: FontWeight.w500,
                    ),
                    BodyText(
                      subtitle,
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BodyText(
                    amount,
                    size: BodySize.small,
                    color: isCredit ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isCredit ? const Color(0xFFE0F2F1) : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: BodyText(
                      type,
                      size: BodySize.small,
                      color: isCredit ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
