import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BodyText(
          'Your Profile',
          size: BodySize.large,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Profile Header
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2.r),
                          ),
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: const Color(0xFFF1F5F5),
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : const AssetImage('assets/images/regular.jpg') as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16.r,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  BodyText(
                    'Paul Chibuikem',
                    size: BodySize.large,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  BodyText(
                    'Plumber',
                    size: BodySize.medium,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16.r, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      BodyText(
                        'San Francisco, CA',
                        size: BodySize.small,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Stats Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildStatCard('Completed Jobs', '120'),
                  SizedBox(width: 12.w),
                  _buildStatCard('Review', '4.9'),
                  SizedBox(width: 12.w),
                  _buildStatCard('Response Time', '1 hr'),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Profile Sections
            _buildSectionHeader('Account'),
            _buildMenuItem('Job History', showDivider: true),
            _buildMenuItem('Change Password'),

            SizedBox(height: 24.h),
            _buildSectionHeader('Contact Information'),
            _buildMenuItem(
              'Phone Number',
              subtitle: '+234 708 372 2938',
              showDivider: true,
            ),
            _buildMenuItem(
              'Email',
              subtitle: 'sophia.carter@email.com',
            ),

            SizedBox(height: 24.h),
            _buildSectionHeader('Payment Methods'),
            _buildMenuItem('Bank Accounts'),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            BodyText(
              label,
              size: BodySize.small,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: BodyText(
          title,
          size: BodySize.medium,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {String? subtitle, bool showDivider = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          title: BodyText(
            title,
            size: BodySize.medium,
            color: AppColors.textPrimary,
          ),
          subtitle: subtitle != null
              ? BodyText(
                  subtitle,
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                )
              : null,
          trailing: Icon(Icons.arrow_forward_ios, size: 16.r, color: AppColors.textPrimary),
          onTap: () {},
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Divider(height: 1),
          ),
      ],
    );
  }
}
