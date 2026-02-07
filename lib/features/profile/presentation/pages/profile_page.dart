import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../../artisan_profile/domain/models/artisan_profile.dart';
import '../../../artisan_profile/domain/models/wallet_balance.dart';
import '../../../artisan_profile/presentation/providers/artisan_profile_provider.dart';
import '../../../artisan_profile/presentation/providers/artisan_wallet_provider.dart';
import '../../../client_profile/domain/models/client_profile.dart';
import '../../../client_profile/presentation/providers/client_profile_provider.dart';
import '../providers/profile_actions_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isLoggingOut = false;

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
      await _uploadProfileImage(File(selectedImage.path));
    }
  }

  Future<void> _uploadProfileImage(File file) async {
    if (_isUploadingImage) {
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      await ref
          .read(profileRemoteDataSourceProvider)
          .updateProfilePicture(file);

      ref.invalidate(artisanProfileProvider);
      ref.invalidate(clientProfileProvider);
      ref.invalidate(authProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );

    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return _buildErrorState('User not logged in', () {
            ref.invalidate(authProvider);
          });
        }

        return user.role == UserRole.artisan
            ? _buildArtisanProfile()
            : _buildClientProfile();
      },
      loading: () => _buildLoadingSkeleton(),
      error: (error, stack) => _buildErrorState(
        'Failed to load user',
        () => ref.invalidate(authProvider),
      ),
    );
  }

  Widget _buildArtisanProfile() {
    final profileAsync = ref.watch(artisanProfileProvider);
    final walletAsync = ref.watch(artisanWalletProvider);
    final authAsync = ref.watch(authProvider);

    return profileAsync.when(
      data: (profile) => walletAsync.when(
        data: (wallet) => _buildArtisanContent(
          profile,
          wallet,
          authAsync.value?.email,
          authAsync.value?.phoneNumber,
        ),
        loading: () => _buildArtisanContent(
          profile,
          null,
          authAsync.value?.email,
          authAsync.value?.phoneNumber,
        ),
        error: (error, stack) => _buildArtisanContent(
          profile,
          null,
          authAsync.value?.email,
          authAsync.value?.phoneNumber,
        ),
      ),
      loading: () => _buildLoadingSkeleton(),
      error: (error, stack) => _buildErrorState(
        'Failed to load profile',
        () => ref.invalidate(artisanProfileProvider),
      ),
    );
  }

  Widget _buildClientProfile() {
    final profileAsync = ref.watch(clientProfileProvider);

    return profileAsync.when(
      data: (profile) => _buildClientContent(profile),
      loading: () => _buildLoadingSkeleton(),
      error: (error, stack) => _buildErrorState(
        'Failed to load profile',
        () => ref.invalidate(clientProfileProvider),
      ),
    );
  }

  Widget _buildArtisanContent(
    ArtisanProfile profile,
    WalletBalance? wallet,
    String? email,
    String? phoneNumber,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildProfileHeader(
              name: profile.fullName,
              role: profile.skills?.isNotEmpty == true
                  ? profile.skills!.first
                  : 'Artisan',
              location: profile.location ?? 'Not specified',
              imageUrl: profile.profilePictureUrl,
            ),
            SizedBox(height: 32.h),
            _buildArtisanStats(profile, wallet),
            SizedBox(height: 32.h),
            _buildSections(
              bio: profile.bio,
              email: email ?? 'Not available',
              phoneNumber: phoneNumber ?? 'Not available',
              isArtisan: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientContent(ClientProfile profile) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildProfileHeader(
              name: profile.fullName,
              role: 'Client',
              location: 'Location not available',
              imageUrl: profile.profilePictureUrl,
            ),
            SizedBox(height: 32.h),
            _buildClientStats(profile),
            SizedBox(height: 32.h),
            _buildSections(
              bio: profile.bio,
              email: profile.email,
              phoneNumber: profile.phoneNumber,
              isArtisan: false,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: BodyText(
        'Your Profile',
        size: BodySize.large,
        fontWeight: FontWeight.w500,
      ),
      centerTitle: false,
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String role,
    required String location,
    String? imageUrl,
  }) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2.r,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: const Color(0xFFF1F5F5),
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage(
                                      'assets/images/regular.jpg',
                                    ))
                              as ImageProvider,
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
                if (_isUploadingImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 26.r,
                          height: 26.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          BodyText(name, size: BodySize.large, fontWeight: FontWeight.w500),
          SizedBox(height: 4.h),
          BodyText(role, size: BodySize.medium, color: AppColors.textSecondary),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16.r, color: AppColors.primary),
              SizedBox(width: 4.w),
              BodyText(
                location,
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanStats(ArtisanProfile profile, WalletBalance? wallet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildStatCard('Total Earnings', wallet?.formattedEarnings ?? '₦0'),
          SizedBox(width: 12.w),
          _buildStatCard(
            'Completed Jobs',
            profile.totalJobsCompleted.toString(),
          ),
          SizedBox(width: 12.w),
          _buildStatCard(
            'Rating',
            profile.averageRating > 0
                ? profile.averageRating.toStringAsFixed(1)
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildClientStats(ClientProfile profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildStatCard(
            'Account Status',
            profile.isActive ? 'Active' : 'Inactive',
          ),
          SizedBox(width: 12.w),
          _buildStatCard(
            'Email Status',
            profile.isEmailVerified ? 'Verified' : 'Unverified',
          ),
          SizedBox(width: 12.w),
          _buildStatCard('Member Since', _formatDate(profile.createdAt)),
        ],
      ),
    );
  }

  Widget _buildSections({
    String? bio,
    required String email,
    String? phoneNumber,
    required bool isArtisan,
  }) {
    return Column(
      children: [
        _buildSectionHeader('Account'),
        _buildMenuItem(
          'Job History',
          onTap: () => context.push(AppRoutes.jobHistory),
        ),
        _buildMenuItem('Change Password', onTap: _showChangePasswordDialog),
        SizedBox(height: 24.h),
        _buildSectionHeader('Contact Information'),
        if (phoneNumber != null)
          _buildMenuItem(
            'Phone Number',
            subtitle: phoneNumber,
            showArrow: false,
            isClickable: false,
          ),
        _buildMenuItem(
          'Email',
          subtitle: email,
          showArrow: false,
          isClickable: false,
        ),
        // TODO: Re-enable when saved bank-account architecture is implemented.
        // if (isArtisan) ...[
        //   SizedBox(height: 24.h),
        //   _buildSectionHeader('Payment Methods'),
        //   _buildMenuItem('Bank Accounts'),
        // ],
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              icon: _isLoggingOut
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: BodyText(
                _isLoggingOut ? 'Logging out...' : 'Logout',
                size: BodySize.medium,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title, {
    String? subtitle,
    bool showDivider = false,
    bool showArrow = true,
    bool isClickable = true,
    VoidCallback? onTap,
  }) {
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
          trailing: showArrow
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16.r,
                  color: AppColors.textPrimary,
                )
              : null,
          onTap: isClickable ? (onTap ?? () {}) : null,
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Divider(height: 1),
          ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 150.w,
                    height: 20.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 100.w,
                    height: 16.h,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildSkeletonCard(),
                  SizedBox(width: 12.w),
                  _buildSkeletonCard(),
                  SizedBox(width: 12.w),
                  _buildSkeletonCard(),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.r),
        ),
        height: 80.h,
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: Colors.red),
            SizedBox(height: 16.h),
            BodyText(
              message,
              size: BodySize.medium,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: BodyText(
                'Retry',
                size: BodySize.medium,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (next.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 8 characters'),
        ),
      );
      return;
    }

    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(profileRemoteDataSourceProvider)
          .changePassword(
            currentPassword: current,
            newPassword: next,
            confirmPassword: confirm,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 320.w,
          maxWidth: width > 600 ? 520 : width * 0.94,
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyText(
                'Change Password',
                size: BodySize.large,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Current password',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _newController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
