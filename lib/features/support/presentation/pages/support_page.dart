import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/support_contact.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../data/mock_support_data.dart';
import '../../domain/models/faq.dart';
import '../widgets/support_category_card.dart';
import '../widgets/faq_item.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  FAQCategory _selectedFAQCategory = FAQCategory.bookings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Header
                _buildHeader(),

                SizedBox(height: 20.h),

                // Support Categories Grid
                _buildCategoriesGrid(),

                SizedBox(height: 24.h),

                // Quick Help Cards (temporarily hidden)
                // _buildQuickHelpSection(),
                SizedBox(height: 28.h),

                // My Support Requests
                // _buildSupportRequestsSection(),

                // SizedBox(height: 28.h),

                // FAQs
                _buildFAQsSection(),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText('Workchop Support', size: HeaderSize.h4),
        SizedBox(height: 1.h),
        BodyText(
          'Get help with bookings, artisans, or payments',
          size: BodySize.small,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20.w,
          mainAxisSpacing: 20.h,
          childAspectRatio: 0.9,
        ),
        itemCount: MockSupportData.supportCategories.length,
        itemBuilder: (context, index) {
          final category = MockSupportData.supportCategories[index];
          return SupportCategoryCard(
            category: category,
            onTap: () {
              _openWhatsAppSupport(
                message:
                    'Hi Workchop Support, I need help with ${category.title.replaceAll('\n', ' ')}.',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFAQsSection() {
    final faqs = MockSupportData.getFAQsByCategory(_selectedFAQCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderText('FAQs', size: HeaderSize.h4),
            GestureDetector(
              onTap: () {
                _openWhatsAppSupport(
                  message:
                      'Hi Workchop Support, I need help with ${_selectedFAQCategory.name} questions.',
                );
              },
              child: BodyText(
                'See all',
                size: BodySize.small,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // FAQ tabs and list
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              // Category tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFAQTab(
                      'Bookings',
                      FAQCategory.bookings,
                      _selectedFAQCategory == FAQCategory.bookings,
                    ),
                    _buildFAQTab(
                      'Payments',
                      FAQCategory.payments,
                      _selectedFAQCategory == FAQCategory.payments,
                    ),
                    _buildFAQTab(
                      'App Guide',
                      FAQCategory.appGuide,
                      _selectedFAQCategory == FAQCategory.appGuide,
                    ),
                    _buildFAQTab(
                      'Safety',
                      FAQCategory.safety,
                      _selectedFAQCategory == FAQCategory.safety,
                    ),
                  ],
                ),
              ),

              // FAQs list
              if (faqs.isEmpty)
                Padding(
                  padding: EdgeInsets.all(24.r),
                  child: BodyText(
                    'No FAQs available',
                    size: BodySize.medium,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...faqs
                    .take(3)
                    .map(
                      (faq) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: FAQItem(
                          faq: faq,
                          onTap: () {
                            _openWhatsAppSupport(
                              message:
                                  'Hi Workchop Support, I need help with this FAQ: ${faq.question}',
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQTab(String label, FAQCategory category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFAQCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: BodyText(
          label,
          size: BodySize.small,
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Future<void> _openWhatsAppSupport({required String message}) async {
    final encoded = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse(
      'https://wa.me/${SupportContact.whatsappNumber}?text=$encoded',
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    final openedDialer = await launchPhoneDialer(SupportContact.phone);
    if (!openedDialer || !mounted) return;
  }
}
